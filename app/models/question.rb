class Question
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Taggable
  
  include ActiveModel::ForbiddenAttributesProtection # #rails4

  field :name, type: String
  field :type, type: String
  field :description, type: String
  field :public, type: Boolean, default: false
  field :settings, type: Hash, default: {}
  
  def self.question_types
    ["multi","single", "text", "exit_q", "number"]
  end
  
  validates :type, inclusion: {in: Question.question_types}
  validates_presence_of :name

  embeds_many :question_options
  accepts_nested_attributes_for :question_options, allow_destroy: true

  embeds_many :question_comments

  belongs_to :user   # TODO can questions exist without user?
  belongs_to :original_question, class_name: "Question", inverse_of: :copied_questions
  has_many :copied_questions, class_name: "Question", inverse_of: :original_question

  has_and_belongs_to_many :collaborators, class_name: "User", inverse_of: :shared_questions
  index :collaborator_ids, sparse: true


  # this is where we setup getting the service objects
  def service
    case type 
    when "text"
      TextQuestion.new(self)
    when "single"
      SingleChoiceQuestion.new(self)
    when "multi"
      MultipleChoiceQuestion.new(self)
    when "number"
      NumberQuestion.new(self)
    else
      self
    end
  end

  def comments
    self.question_comments
  end


  def to_survey
    survey = Survey.new
    survey.name = self.name 
    survey.type = self.type
    question_options.each do |qo|
      survey.options.push qo.to_option
    end
    survey.question = self
    survey.settings = self.settings if self.settings
    survey
  end

  def can_be_accessed_by?(_user)
    (collaborators + [user]).include?(_user) || _user.admin
  end
  
  def self.new_from_existing(original_question)
    Question.new.tap do |question|
      question.name = original_question.name
      original_question.question_options.each do |option|
        question.question_options.build(name: option.name, correct: option.correct)
      end
      question.type = original_question.type
      question.original_question = original_question
      question.description = original_question.description
      question.tags = original_question.tags
    end
  end

  def self.public_question_tags(type = nil)
    if type
      self.where(public:true).in(type: type).flat_map(&:tags_array).uniq
    else
      self.where(public:true).flat_map(&:tags_array).uniq
    end
  end

  def self.recently_commented
    self.where("question_comments.created_at" => {"$gte" => Time.now - 14.days}).desc("question_comments.created_at")
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

end
