class OrderSurvey < GenericSurvey
  def initialize(survey)
  	raise "type of survey (#{survey.type}) not correct" if survey.type != "order"
  	super
  end

  def prompt
    I18n.t "surveys.participate.choose-order"
  end
  
  def participate_partial
    "order_list"
  end

  def has_order_options?
    true
  end

  def results_comparable?
    true
  end

  def vote(voter, option_position_pairs)
    if self.survey.running?(false)
      unless self.survey.matches?(voters: voter) #:fixme: is this "enough" concurrency safe?
        self.survey.add_to_set(:voters, voter.to_s)
        if option_position_pairs.respond_to?(:each)
          option_position_pairs.each do |pair|
            pairArray = pair.split(' - ')
            if(pairArray.length == 2)
              self.survey.order_options.where(name: pairArray[0]).first.vote_up(Integer(pairArray[1]))
            end
          end
        elsif option_position_pairs.nil?
          # MC and nothing selected
        else
          pairArray = option_position_pairs.split(' - ')
          if(pairArray.length == 2)
              self.survey.order_options.where(name: pairArray[0]).first.vote_up(Integer(pairArray[1]))
            end
        end
        self.survey.add_to_set("voters_hash."+voter.to_s, (option_position_pairs || :no_answer))
        self.survey.track_vote(voter)
        return true
      end
    end
    return false
  end

end