class ChoiceQuestion < GenericQuestion
  def initialize(question)
    super
  end
  
  def to_survey
    ChoiceSurvey.new(self.question.to_survey)
  end
  
  def has_options?
    true
  end

  def has_answer_pairs?
    false
  end
  
end