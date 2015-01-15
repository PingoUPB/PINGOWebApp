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

  def findAnswerPairID(anzwer1, anzwer2)
    ap = self.survey.answer_pairs.where(answer1: anzwer1, answer2: anzwer2).first
    if ap.blank?
        raise "Couldn't find answer_pair: " + anzwer1 + " - " + anzwer2
    else
      return ap.id
    end
  end

    def vote(voter, word_pairs)
    if self.survey.running?(false)
      unless self.survey.matches?(voters: voter) #:fixme: is this "enough" concurrency safe?
        self.survey.add_to_set(:voters, voter.to_s)
        if word_pairs.respond_to?(:each)
          word_pairs.each do |pair|
            pairArray = pair.split(' - ')
            if(pairArray.length == 2)
              self.survey.answer_pairs.where(answer1: pairArray[0], answer2: pairArray[1]).first.vote_up
            end
          end
        elsif word_pairs.nil?
          # MC and nothing selected
        else
          pairArray = word_pairs.split(' - ')
          if(pairArray.length == 2)
              self.survey.answer_pairs.where(answer1: pairArray[0], answer2: pairArray[1]).first.vote_up
            end
        end
        self.survey.add_to_set("voters_hash."+voter.to_s, (word_pairs || :no_answer))
        self.survey.track_vote(voter)
        return true
      end
    end
    return false
  end

end