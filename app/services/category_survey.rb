class CategorySurvey < GenericSurvey
  def initialize(survey)
  	raise "type of survey (#{survey.type}) not correct" if survey.type != "category"
  	super
  end

  def prompt
    I18n.t "surveys.participate.choose-order"
  end
  
  def participate_partial
    "category_lists"
  end

  def has_categories?
    true
  end

  def results_comparable?
    true
  end

  def vote(voter, category_subwords_pairs)
    if self.survey.running?(false)
      unless self.survey.matches?(voters: voter) #:fixme: is this "enough" concurrency safe?
        self.survey.add_to_set(:voters, voter.to_s)
        if category_subwords_pairs.respond_to?(:each)
          category_subwords_pairs.each do |pair|
            pairArray = pair.split(' - ')
            pairArray[1].split(';').each do |sub_word|
              self.survey.sub_words.where(name: sub_word).first.vote_up(pairArray[0]) 
            end
          end
        elsif category_subwords_pairs.nil?
          # MC and nothing selected
        else
          pairArray = category_subwords_pairs.split(' - ')
          pairArray[1].split(';').each do |sub_word|
            self.survey.sub_words.where(name: sub_word).first.vote_up(pairArray[0])
          end
        end
        self.survey.add_to_set("voters_hash."+voter.to_s, (category_subwords_pairs || :no_answer))
        self.survey.track_vote(voter)
        return true
      end
    end
    return false
  end

end