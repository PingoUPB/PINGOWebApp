class DragDropSurvey < GenericSurvey
  def initialize(survey)
  	raise "type of survey (#{survey.type}) not correct" if survey.type != "dragdrop"
  	super
  end

  def prompt
    I18n.t "surveys.participate.dragdrop"
  end
  
  def participate_partial
    "dragdrop_option"
  end

   # VIEW OPTIONS
  def has_options?
    false
  end

  def has_answer_pairs?
    true
  end

  def has_settings?
    false
  end

  def results_comparable?
    true
  end
end