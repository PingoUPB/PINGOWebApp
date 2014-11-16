class DragDropQuestion < GenericQuestion
  def initialize(question = Question.new(type: "dragdrop"))
    raise "type of question not correct" if question.type != "dragdrop"
    super
    self.question.type = "dragdrop" unless self.question.persisted?
  end

  def has_options?
    false
  end

  def has_answer_pairs?
    true
  end

  def has_settings?
    true
  end

  def form_partial
    "dragdrop_form"
  end

  def to_survey
    DragDropSurvey.new(self.question.to_survey)
  end
end