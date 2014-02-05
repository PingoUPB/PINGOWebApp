class NumberSurvey < GenericSurvey

  def vote(voter, option)
    if running?(false)
      unless matches?(voters: voter)
        add_to_set(:voters, voter.to_s)
        begin
          push("voters_hash.numbers", BigDecimal(option.gsub(",", ".")).to_f)
        rescue ; end
        track_vote(voter)
        true
      end
    else
      false
    end
  end

  def raw_results
    if self.total_votes > 0
      self.voters_hash['numbers'].map do |word|
        OpenStruct.new voter_id: nil, answer: word
      end
    else
      []
    end
  end

  # VIEW options

  def prompt
    I18n.t "surveys.participate.choose-number"
  end

  def max_answers
    1
  end

  def participate_partial
    "number_input_field"
  end

  def number_counts(kind = :clustered, locale = :en)
    if voters_hash and voters_hash["numbers"]
      if kind == :clustered
        clustered_votes = Statistics.cluster(voters_hash["numbers"].map do |number|
          Statistics.sigfig_to_s(number,2)
        end)
        Hash[clustered_votes.map do |cluster|
          cluster = [cluster] unless cluster.respond_to? :flatten
          min = cluster.min.to_s
          max = cluster.max.to_s
          if locale == :de
            max = max.sub(".", ",")
            min = min.sub(".", ",")
          end
          [min == max ? max.to_s : "#{min}-#{max}", cluster.size]
        end
        ]
      elsif kind == :table
        votes = voters_hash["numbers"].group_by { |number| number }.map do |key, val| 
          [ActionController::Base.helpers.number_with_delimiter(key, locale: locale), val.count]
        end 

        Hash[votes]
      else
        Hash[Statistics.histogram voters_hash["numbers"]]
      end
    else
      {}
    end
  end

  def word_counts(locale)
    number_counts :table, locale
  end
  
  def terms_numeric?
    true
  end

  def voting_avg
    if voters_hash and voters_hash["numbers"]
      Statistics.avg voters_hash["numbers"]
    end
  end

  def voting_median
    if voters_hash and voters_hash["numbers"]
      Statistics.median voters_hash["numbers"]
    end
  end

  def voting_stdev
    if voters_hash and voters_hash["numbers"]
      Statistics.stdev voters_hash["numbers"]
    end
  end

end
