class MultipleChoiceQuestion < ChoiceQuestion
  def initialize(question = Question.new(type: "multi"))
    raise "type of question not correct" if question.type != "multi"
    super
    self.question.type = "multi" unless self.question.persisted?
  end
  
  def form_partial
    "multi_form"
  end
end