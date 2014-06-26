class MultipleChoiceQuestion < ChoiceQuestion
  def initialize(question = Question.new(type: "multi"))
    raise "type of question not correct" if question.type != "multi"
    super
    self.question.type = "multi" unless self.question.persisted?
  end
  
  def form_partial
    "multi_form"
  end

  def transform
    self.question.type = "single"
    unless self.question.question_options.select{|o| o.correct }.size <= 1 
      self.question.question_options = self.question.question_options.map do |o|
        o.correct = false
        o
      end
    end
    self.question.save
  end
end
