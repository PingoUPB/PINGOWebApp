class DragDropSurvey < GenericSurvey
  def initialize(survey)
  	raise "type of survey (#{survey.type}) not correct" if survey.type != "drag_drop"
  	super
  end

  def prompt
    I18n.t "surveys.participate.drag_drop"
  end
  
  def participate_partial
    "drag_drop_option"
  end

   # VIEW OPTIONS
  def has_options?
    false
  end

  def has_answer_pairs?
    true
  end

  def has_settings?
    true
  end

  def results_comparable?
    true
  end
end