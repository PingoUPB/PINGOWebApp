class NumberQuestion < GenericQuestion
  def initialize(question = Question.new(type: "number"))
    raise "type of question not correct" if question.type != "number"
    super
    self.question.type = "number" unless self.question.persisted?
  end
  
  def to_survey
    NumberSurvey.new(self.question.to_survey)
  end
  
  def form_partial
    "number_form"
  end
  
end