class TextQuestion < GenericQuestion
  def initialize(question = Question.new(type: "text"))
    raise "type of question not correct" if question.type != "text"
    super
    self.question.type = "text" unless self.question.persisted?
  end
  
  def to_survey
    TextSurvey.new(self.question.to_survey)
  end
  
  def form_partial
    "text_form"
  end

  def has_settings?
    true
  end


  
end