class GenericQuestion < Delegator
  
  def initialize(question)
    super
    @question = question
  end
  
  def __getobj__ # required
    @question
  end
  
  def __setobj__(obj)
      @question = obj # change delegation object
  end
  
  def to_model
    @question.to_model
  end

  def has_settings?
    false
  end

  def has_answer_pairs?
    false
  end

  def has_order_options?
    false
  end

  def has_categories?
    false
  end

  def add_setting(key, value)
    @question.settings ||= {}
    @question.settings[key.to_s] = value.to_s
  end
  
  def self.model_name
    Question.model_name
  end
  
  def self.reflect_on_association arg
    Question.reflect_on_association arg
  end
  
  alias_method :question, :__getobj__ # reader for survey
  
end