class OrderQuestion < GenericQuestion
  def initialize(question = Question.new(type: "order"))
    raise "type of question not correct" if question.type != "order"
    super
    self.question.type = "order" unless self.question.persisted?
  end

  def has_options?
    false
  end

  def has_answer_pairs?
    false
  end

  def has_order_options?
    true
  end

  def form_partial
    "order_form"
  end

  def to_survey
    OrderSurvey.new(self.question.to_survey)
  end

end