class SingleChoiceSurvey < ChoiceSurvey
  def initialize(survey)
    raise "type of survey (#{survey.type}) not correct" if survey.type != "single"
    super
  end
  
  # VIEW options 
  
  def prompt
    I18n.t "surveys.participate.choose"
  end
  
  def participate_partial
    "radio_option"
  end
  
end