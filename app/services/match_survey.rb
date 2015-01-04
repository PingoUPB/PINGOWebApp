class MatchSurvey < GenericSurvey
  def initialize(survey)
  	raise "type of survey (#{survey.type}) not correct" if survey.type != "match"
  	super
  end

  def prompt
    I18n.t "surveys.participate.choose-match"
  end
  
  def participate_partial
    "match_lists"
  end

  def has_answer_pairs?
    true
  end

  def results_comparable?
    true
  end

  def get_all_answer1
    if(self.survey.answer_pairs.any?)
      answer1s = []
      self.survey.answer_pairs.where(correct: true).each do |pair| 
        answer1s += [pair.answer1]
      end
      return answer1s
    end
  end

  def get_all_answer2
    if(self.survey.answer_pairs.any?)
      answer2s = []
      self.survey.answer_pairs.where(correct: true).each do |pair| 
        answer2s += [pair.answer2]
      end
      return answer2s
    end
  end

end