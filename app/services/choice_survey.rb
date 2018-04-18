class ChoiceSurvey < GenericSurvey

  def initialize(survey)
    super
  end

  def vote(voter, option_ids)
    if self.survey.running?(false)
      unless self.survey._matches?(voters: voter)
        self.survey.add_to_set(voters: voter.to_s)
        if option_ids.respond_to?(:each)
          option_ids.each do |option|
            self.survey.options.find(option).vote_up
          end
        elsif option_ids.nil?
          # MC and nothing selected
        else
          self.survey.options.find(option_ids).vote_up
        end
        self.survey.push(:voters_hash => {voter.to_s => (option_ids || :no_answer)})
        self.survey.track_vote(voter)
        return true
      end
    end
    return false
  end

  def correct_answers
    if self.options.where(correct: false).count > 0
      self.options.where(correct: true).map { |o| o.id.to_s}
    elsif self.original_survey && self.original_survey.options.where(correct: false).count > 0
             # ^^ why is this not always available? TODO
      self.original_survey.options.where(correct: true).map { |o| o.id.to_s}
    end
  end

  def changed_behaviour
    if self.original_survey
      matrix = Hash.new(0)
      self.original_survey.voters_hash.each do |voter, old_options|
        new_options = self.voters_hash[voter] || [:no_participation]

        if old_options.nil?
          matrix[[[], new_options]] += 1
        else
          matrix[[old_options, new_options]] += 1
        end
      end
      new_voters = self.voters_hash.keys - self.original_survey.voters_hash.keys
      new_voters.each do |voter|
        matrix[[[:no_participation], self.voters_hash[voter]]] += 1
      end
      matrix
    else
      nil
    end
  end

  def changed_behaviour_aggregated
    if self.original_survey
      matrix = Hash.new(0)
      self.original_survey.voters_hash.each do |voter, old_options|
        if self.voters_hash[voter].nil?
          new_options = [:no_participation]
        else
          new_options = (self.voters_hash[voter] == self.correct_answers)? [:right] : [:wrong]
        end
        matrix[[(old_options == self.original_survey.service.correct_answers)? [:right] : [:wrong], new_options]] += 1
      end
      new_voters = self.voters_hash.keys - self.original_survey.voters_hash.keys
      new_voters.each do |voter|
        matrix[[[:no_participation], (self.voters_hash[voter] == self.service.correct_answers)? [:right] : [:wrong] ]] += 1
      end
      matrix
    else
      nil
    end
  end

  def raw_results
    results = []

    # voters_hash is nil if there are no votes
    if self.total_votes > 0
      self.voters_hash.each do |voter_id, options|

        if options.respond_to?(:each)
            options.each do |option|
              results << OpenStruct.new(voter_id: voter_id, answer: self.survey.options.find(option).name)
            end
        else
          results << OpenStruct.new(voter_id: voter_id, answer: options)
        end
      end
    end

    results
  end

  # returns options concatenated as string
  def options_s
    self.options.map(&:name).to_csv(row_sep: "")
  end

  # VIEW OPTIONS
  def has_options?
    true
  end

  def results_comparable?
    true
  end

end
