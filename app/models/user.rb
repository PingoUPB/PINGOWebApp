class User
  include Mongoid::Document
  include Mongoid::Timestamps::Created # save registration date
  
  # Include default devise modules. Others available are:
  # :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable  

# Vor-, Nachname, Lehrstuhl, Fakultät, Welche Lehrveranstaltungen/user comment(nur bei Registrierung)

  field :first_name, type: String
  field :last_name, type: String
  field :chair, type: String
  field :faculty, type: String
  field :organization, type: String
  field :user_comment, type: String

  field :wants_sound, type: Boolean, default: false
  
  field :allow_external_analytics, type: Boolean, default: true
  
  field :newsletter, type: Boolean, default: false

  field :admin, type: Boolean, default: false
  field :email, type: String
  field :encrypted_password, type: String

  field :reset_password_token, type: String ## Recoverable
  field :reset_password_sent_at, type: Time ## Recoverable
  field :remember_created_at, type: Time ## Rememberable

  ## Trackable
  field :sign_in_count, type: Integer
  field :current_sign_in_at, type: Time
  field :last_sign_in_at, type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip, type: String
  
  ## Token authenticatable
  field :authentication_token, type: String
  
  field :quick_start_settings, type: Hash, default: Hash.new

  field :ppt_settings, type: Hash, default: Hash.new
  
  field :newsletter_optin_token, type: String
  field :newsletter_confirmed_at, type: Time, default: nil
  
  validates :first_name, presence: true
  validates :last_name, presence: true

  validates :organization, presence: true
  validates_uniqueness_of :name, :email, case_sensitive: false
  
  #attr_accessible :first_name, :last_name, :faculty, :chair, :organization, :user_comment, :email, :password, :password_confirmation, :remember_me, :wants_sound, :newsletter, :allow_external_analytics, :ppt_settings
  
  has_many :events, dependent: :destroy
  has_many :questions, dependent: :destroy
  
  has_and_belongs_to_many :shared_events, class_name: "Event", inverse_of: :collaborators
  has_and_belongs_to_many :shared_questions, class_name: "Question", inverse_of: :collaborators
  has_and_belongs_to_many :contacts, class_name: "User", inverse_of: nil
  
  
  # returns latest session from user.
  # creates a new one and returns it if the user has no session
  def latest_event
    latest_event = self.events.desc(:created_at).limit(1)[0]
    if latest_event.nil? #oops, user never had a session before...
      latest_event = self.events.build
    end
    latest_event
  end
  
  def voter_id #used as "voter-string" to ensure that logged in users can only vote once
    "USER_"+self.id.to_s
  end

  def name
    [first_name, last_name].join(" ")
  end
  
  def contact_names_and_ids
    (self.contacts || []).map do |c|
      {
        id: c.id.to_s,
        name: c.name
      }
    end
  end

  def question_tags(type = nil)
    if type
      self.questions.in(type: type).pluck(:tags).flatten.uniq if self.questions
    else
      self.questions.pluck(:tags).flatten.uniq if self.questions
    end
  end
  
  def shared_question_tags(type = nil)
    if type
      self.shared_questions.in(type: type).pluck(:tags).flatten.uniq
    else
      self.shared_questions.pluck(:tags).flatten.uniq
    end
  end
  
  def all_question_tags(type = nil)
    (question_tags(type) + shared_question_tags(type)).uniq
  end
  
  
  # https://gist.github.com/josevalim/fb706b1e933ef01e4fb6
  def ensure_authentication_token!
      if authentication_token.blank?
        self.authentication_token = generate_authentication_token
      end
  end

    private
  
  def generate_authentication_token
      loop do
        token = Devise.friendly_token
        break token unless User.where(authentication_token: token).first
      end
  end
  
end
