class TextSurvey < GenericSurvey

  ONE_ANSWER = "one_answer"
  THREE_ANSWERS = "up_to_three_answers"
  MULTI_ANSWERS = "multiple_answers"


  def vote(voter, option)
    if running?(false)
      unless matches?(voters: voter)
        add_to_set(voters: voter.to_s)
        if option.respond_to?(:each)
          option.first(max_answers).each do |o|
            push("voters_hash.words", o.to_s.strip) unless o.blank?
          end
        else
          push("voters_hash.words", option.to_s)
        end
        track_vote(voter)
        true
      end
    else
      false
    end
  end

  def raw_results
    if self.total_votes > 0 && self.voters_hash
      self.voters_hash['words'].map do |word|
        OpenStruct.new voter_id: nil, answer: word
      end
    else
      []
    end
  end

  # VIEW options

  def prompt
    I18n.t "surveys.participate.choose-text"
  end

  def has_settings?
    true
  end

  def multi?
    settings && (survey.settings["answers"] == MULTI_ANSWERS || survey.settings["answers"] == THREE_ANSWERS)
  end

  def max_answers
    return 1 unless survey.settings
    if survey.settings["answers"] == ONE_ANSWER
      1
    elsif survey.settings["answers"] == THREE_ANSWERS
      3
    else
      9
    end
  end

  def participate_partial
    "text_input_field"
  end

  def word_counts(locale = :en)
    if voters_hash and voters_hash["words"]
      Hash[@survey.voters_hash["words"].reject do |word|
        Obscenity.profane?(word)
      end.group_by(&:capitalize).map do |k, v|
        [k, v.length]
      end]
    else
      {}
    end
  end

end

