class MultipleChoiceSurvey < ChoiceSurvey
  def initialize(survey)
    raise "type of survey (#{survey.type}) not correct" if survey.type != "multi"
    super
  end
  
  # VIEW options 
  
  def prompt
    I18n.t "surveys.participate.choose-multi"
  end
  
  def participate_partial
    "check_box_option"
  end
end