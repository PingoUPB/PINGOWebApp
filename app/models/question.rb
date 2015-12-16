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
    ["multi", "single", "text", "exit_q", "number", "match", "order", "category"]
  end
  
  validates :type, inclusion: {in: Question.question_types}
  validates_presence_of :name

  embeds_many :question_options
  accepts_nested_attributes_for :question_options, allow_destroy: true

  embeds_many :question_comments

  embeds_many :answer_pairs
  accepts_nested_attributes_for :answer_pairs, allow_destroy: true

  embeds_many :order_options
  accepts_nested_attributes_for :order_options, allow_destroy: true

  embeds_one :relative_option_order_object
  accepts_nested_attributes_for :relative_option_order_object, allow_destroy: true

  embeds_many :categories
  accepts_nested_attributes_for :categories, allow_destroy: true

  embeds_many :sub_words
  accepts_nested_attributes_for :sub_words, allow_destroy: true

  belongs_to :user   # TODO can questions exist without user?
  belongs_to :original_question, class_name: "Question", inverse_of: :copied_questions
  has_many :copied_questions, class_name: "Question", inverse_of: :original_question

  has_and_belongs_to_many :collaborators, class_name: "User", inverse_of: :shared_questions
  index :collaborator_ids, sparse: true

  after_save :delete_all_false_answer_pairs, :fill_up_answer_pairs

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
    when "match"
      MatchQuestion.new(self)
    when "order"
      OrderQuestion.new(self)
    when "category"
      CategoryQuestion.new(self)
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
    answer_pairs.each do |ap|
      survey.answer_pairs.push ap
    end
    order_options.each do |oo|
      survey.order_options.push oo
    end
    categories.each do |ca|
      survey.categories.push ca
    end
    sub_words.each do |sw|
      survey.sub_words.push sw
    end
    survey.relative_option_order_object = self.relative_option_order_object
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
      original_question.answer_pairs.each do |pair|
        question.answer_pairs.build(
          answer1: pair.answer1, 
          answer2: pair.answer2,
          correct: pair.correct)
      end
      original_question.order_options.each do |option|
        question.order_options.build(name: option.name, position: option.position)
      end
      question.relative_option_order_object = original_question.relative_option_order_object
      original_question.categories.each do |category|
        question.categories.build(name: category.name, sub_words: category.sub_words)
      end
      original_question.sub_words.each do |sub_word|
        question.sub_words.build(name: sub_word.name, category: sub_word.category)
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

  def delete_all_false_answer_pairs
    if(self.answer_pairs.any?)
      self.answer_pairs.where(correct: false).each do |pair|
        pair.delete
      end
    end
  end

  # adds all wrong answer pairs to the collection answer_pairs of the just saved match question
  def fill_up_answer_pairs
    if(self.answer_pairs.any?)
      self.answer_pairs.where(correct: true).each do |pair1|
        self.answer_pairs.where(correct: true).each do |pair2|
          if(pair1.answer1 != pair2.answer1)
            if(pair1.answer2 != pair2.answer2)
              self.answer_pairs.create(:answer1 => pair1.answer1, :answer2 => pair2.answer2, :correct => false)
            end
          end
        end
      end
    end
  end

end