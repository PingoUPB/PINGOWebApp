class MatchQuestion < GenericQuestion
  def initialize(question = Question.new(type: "match"))
    raise "type of question not correct" if question.type != "match"
    super
    self.question.type = "match" unless self.question.persisted?
  end

  def has_answer_pairs?
    true
  end

  def form_partial
    "match_form"
  end

  def to_survey
    MatchSurvey.new(self.question.to_survey)
  end

end