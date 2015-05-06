class CategoryQuestion < GenericQuestion
  def initialize(question = Question.new(type: "category"))
    raise "type of question not correct" if question.type != "category"
    super
    self.question.type = "category" unless self.question.persisted?
  end

  def has_options?
    false
  end

  def has_categories?
    true
  end

  def form_partial
    "category_form"
  end

  def to_survey
    CategorySurvey.new(self.question.to_survey)
  end

end