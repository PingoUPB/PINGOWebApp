class SingleChoiceQuestion < ChoiceQuestion
  def initialize(question = Question.new(type: "single"))
    raise "type of question not correct" if question.type != "single"
    super
    @question.type = "single" unless self.question.persisted?
  end
  
  def form_partial
    "single_form"
  end

  def transform
    self.question.type = "multi"
    self.save
  end
end
