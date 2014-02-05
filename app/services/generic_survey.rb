class GenericSurvey < Delegator
  
  def initialize(survey)
    super
    @survey = survey
  end
  
  def __getobj__ # required
    @survey
  end
  
  def __setobj__(obj)
      @survey = obj # change delegation object
  end
  
  def results_comparable?
    false
  end

  def has_settings?
    false
  end

  def has_options?
    false
  end
  
  def terms_numeric? # are individual answers numeric?
    false
  end

  def add_setting(key, value)
    survey.settings ||= {}
    survey.settings[key.to_s] = value.to_s
  end
  
  alias_method :survey, :__getobj__ # reader for survey
end