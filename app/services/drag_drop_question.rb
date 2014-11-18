class DragDropQuestion < GenericQuestion
  def initialize(question = Question.new(type: "drag_drop"))
    raise "type of question not correct" if question.type != "drag_drop"
    super
    self.question.type = "drag_drop" unless self.question.persisted?
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
    "drag_drop_form"
  end

  def to_survey
    DragDropSurvey.new(self.question.to_survey)
  end
end