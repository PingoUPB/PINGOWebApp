module SurveysHelper
  def word_count_js_array(survey)
    survey.word_counts.map do |word, count|
      {text: word, weight: count}
    end
  end
end
