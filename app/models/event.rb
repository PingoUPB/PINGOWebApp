class Event

  TOKEN_LENGTH = (Rails.env.staging? ? 3 : 4)

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Token

  include ActiveModel::ForbiddenAttributesProtection # #rails4

  token length: TOKEN_LENGTH, contains: :fixed_numeric

  after_save :delete_cache, :refresh_state

  field :name, type: String
  field :description, type: String
  field :state, type: Integer, default: 0 # note this is not a state in a "state" sense but rather just a "version" indicator
                                          # it is used to make sure views are current (js stuff)
  field :mathjax, type: Boolean, default: false

  field :default_question_duration, type: Integer, default: 0

  field :custom_locale, type: String
  validates :custom_locale, inclusion: {in: I18n.available_locales.map(&:to_s) + [""], allow_nil: true}

  belongs_to :user, inverse_of: :events
  has_many :surveys, dependent: :destroy

  has_and_belongs_to_many :collaborators, class_name: "User", inverse_of: :shared_events
  index({ collaborator_ids: 1 }, { sparse: true })

  validates :name, presence: true
  validates :user, presence: true

  def latest_survey(scope = nil)
    if scope == "participate"
      self.surveys.desc(:created_at).limit(1).participate_fields.first
    else
      self.surveys.desc(:created_at).limit(1).display_fields.first
    end
  end

  def self.find_by_id_or_token(token_or_id)
    if token_or_id.length <= TOKEN_LENGTH && !token_or_id.to_s.blank?
      if token_or_id.to_s.length < TOKEN_LENGTH
        Event.find_by_token("0"*(TOKEN_LENGTH - token_or_id.to_s.length) + token_or_id.to_s)
      else
        Event.find_by_token(token_or_id)
      end
    else
      Event.find(token_or_id)
    end
  end

  def delete_cache
    Rails.cache.delete("Events/"+self.id.to_s)
    Rails.cache.delete("last_survey/"+self.id.to_s)
  end

  def refresh_state
    self.inc(state: 1)
  end

  def current_viewers
    PINGO_REDIS.get("vote_hub/" + (self.token.to_s.gsub(/[^a-zA-Z 0-9]/, "")).gsub(/\s/,'-')) unless ENV["USE_JUGGERNAUT"] == "false"
  end

  def mathjax?
    self.mathjax
  end

  # for FORM

  def collaborators_form
    self.collaborators.map(&:id).join(",")
  end

  def collaborators_form=(v)
    self.collaborators = v.split(",").reject(&:blank?).map do |u|
      User.find(u)
    end
  end

  # for token length upgrade purposes
  def self.check_and_upgrade_all_tokens! # upgrades tokens by padding with leading zeros
    results = []
    errors = []
    puts ""
    all_evt_ids = Event.where("this.token.length < #{Event::TOKEN_LENGTH.to_s}").only(:id).map(&:id)
    puts "#{all_evt_ids.count.to_s} events"
    all_evt_ids.each_with_index do |event_id, i|
      e = Event.find(event_id)
      print "#{i.to_s}: #{e.token.to_s} .. "
      old_token = e.token.to_s
      # FIXME: Warning: The following line adds two zeros (hard coded!). Please adapt for your token length.
      new_token =  "00#{e.token.to_s}" # ("%0#{Event::TOKEN_LENGTH.to_s}d" % e.token.to_s)
      print "#{old_token} -> #{new_token} .. "
      begin
        e.set(:token, new_token)
      rescue ex
        errors << old_token
        puts "..error"
      end
      results << [old_token, e.token]
      puts "..ok"
    end
    [results, errors]
  end

end
