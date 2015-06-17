class Survey
  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  include ActiveModel::ForbiddenAttributesProtection # #rails4

  after_save :delete_cache, :refresh_event_state

  belongs_to :original_survey, class_name: "Survey", inverse_of: :repeated_surveys
  has_many :repeated_surveys, class_name: "Survey", inverse_of: :original_survey
  
  embeds_many :options
  accepts_nested_attributes_for :options, :allow_destroy => true

  embeds_many :answer_pairs
  accepts_nested_attributes_for :answer_pairs, :allow_destroy => true

  embeds_many :order_options
  accepts_nested_attributes_for :order_options, :allow_destroy => true

  embeds_one :relative_option_order_object
  accepts_nested_attributes_for :relative_option_order_object, :allow_destroy => true

  embeds_many :categories
  accepts_nested_attributes_for :categories, :allow_destroy => true

  embeds_many :sub_words
  accepts_nested_attributes_for :sub_words, :allow_destroy => true
    
  field :name, type: String
  field :description, type: String
  
  field :starts, type: DateTime
  field :ends, type: DateTime
  
  field :voters, type: Array
  field :voters_hash, type: Hash
  
  field :quick, type: Boolean
  field :multi, type: Boolean
  field :exit_q, type: Boolean, default: false

  field :settings, type: Hash, default: {}
  
  field :type, type: String
  validates :type, inclusion: {in: Question.question_types}

  belongs_to :event, index: true
  
  belongs_to :question
  
  scope :current, where(:starts.gte => DateTime.now).and(:ends.lt => DateTime.now)
  scope :display_fields, only(:description, :ends, :name, :options, :answer_pairs, 
    :order_options, :relative_option_order_object, :starts, :event_id, :quick, 
    :created_at, :multi, :type, :settings, :voters, :voters_hash, :original_survey_id, 
    :exit_q, :question_id, :categories, :sub_words)
  scope :participate_fields, only(:description, :ends, :name, :options, :answer_pairs, 
    :order_options, :relative_option_order_object, :starts, :event_id, :quick, :multi, 
    :type, :exit_q, :settings, :categories, :sub_words)
  scope :worker_fields, only(:voters, :multi, :type, :starts, :ends)
  
  validates :event, presence: true
  
  # this is where we setup getting the service objects
  def service
    case type 
    when "text"
      TextSurvey.new(self)
    when "single"
      SingleChoiceSurvey.new(self)
    when "multi"
      MultipleChoiceSurvey.new(self)
    when "number"
      NumberSurvey.new(self)
    when "exit_q"
      ExitSurvey.new(self)
    when "match"
      MatchSurvey.new(self)
    when "order"
      OrderSurvey.new(self)
    when "category"
      CategorySurvey.new(self)  
    else
      self
    end
  end
  
  def user
    self.event.user
  end
  
  def collaborators
    self.event.collaborators || []
  end
  
  def total_votes
    unless self.voters.nil?
      self.voters.count
    else
      0
    end
  end
  
  def running?(strict = true)
    self.starts && self.starts <= DateTime.now && ((self.ends && self.ends > (DateTime.now - (strict ? 0 : 1.seconds))) || self.ends.nil?)
  end
  
  def start!(duration = 0)
    return false if self.running?(true)
    self.ends = nil
    self.ends = DateTime.now + duration.seconds unless duration == 0
    self.starts = DateTime.now
    self.save!
  end
  
  def stop!(duration = 0)
    return false unless self.running?(true)
    self.ends = DateTime.now + duration.seconds
    self.save!
  end

  
  def time_left(milliseconds = false)
    m = (milliseconds ? 1000 : 1)
    return 0 if !self.running? || !self.ends
    ((self.ends - DateTime.now) * 24 * 60 * 60 * m).to_i
  end

  # :nocov:
  def track_vote(vid)
    if ENV["ANALYTICS"] == "true"
      begin #  we do not want anything from this tracking to produce an error
        a_vote = Vote.new
        a_vote.time_left = self.time_left(true)
        a_vote.session_uri = self.event.token.to_s+"/"+self.id.to_s
        a_vote.duration = ((self.ends - self.starts) * 24 * 60 * 60).to_i if self.ends
        a_vote.voter_id = vid.to_s
        a_vote.save!
      rescue ; end
    end
  end
  # :nocov:
  
  def mathjax?
    self.event.mathjax?
  end

  private
  def delete_cache
    puts "Deleting cache..." if Rails.env.development?
    Rails.cache.delete("Surveys/"+self.id.to_s)
    Rails.cache.delete("last_survey/"+self.event.id.to_s)
    self.event.delete_cache
  end
  
  def refresh_event_state
    self.event.refresh_state
  end  
end
