class ExitSurvey < SingleChoiceSurvey
  def prompt
    I18n.t "survey.participate.rate_lecture"
  end
end