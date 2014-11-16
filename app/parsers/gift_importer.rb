class GiftImporter
  def import (gift_file, user, tags)
    errors = []
    successes = []
    begin
      gift_string = gift_file.read
      gift_string = Converter.new.convert_to_utf8 gift_string
      # Leerzeile an String anhängen
      gift_string << "\n\n"

      # String parsen und über Fragen iterieren, dabei nicht unterstützte fragen merken
      questions = GiftParser.new.parse(gift_string).questions
      questions.each do |question, index|
        q = Question.new

        if question.is_a? Gift::TrueFalseQuestion
          # Bei True/False-Fragen müssen die zwei Antwortoptionen explizit eingetragen werden.
          q = Question.new(type:"single").service
        elsif question.is_a? Gift::MultipleChoiceQuestion
          # Wenn die Frage ein Gewicht hat, hat sie potentiell mehrere richtige Antworten
          unless question.answers[0][:weight].nil?
            q = Question.new(type:"multi").service
          else
            q = Question.new(type:"single").service
          end
        elsif question.is_a?(Gift::ShortAnswerQuestion) || question.is_a?(Gift::EssayQuestion)
          q = Question.new(type:"text").service
        elsif question.is_a? Gift::NumericQuestion
          q = Question.new(type:"number")
        elsif question.is_a? Gift::DragDropQuestion
          q = Question.new(type:"dragdrop")
        elsif question.is_a?(Gift::DescriptionQuestion) || question.is_a?(Gift::MatchQuestion) || question.is_a?(Gift::FillInQuestion)
          # Abfrage nicht unterstützter Typen
          errors << {"type" => "unsupported_type", "text" => question.text}
          next
        else
          # Wenn der Fragetyp unbekannt ist wird die Frage nicht importiert sondern gemerkt
          errors << {"type" => "unknown_type", "text" => question.text}
          next
        end

        # Fragetext setzen
        q.name = question.text

        # Antwortoptionen setzen
        # Zunächst Ausnahme für True/False, Numeric und ShortAnswer-Fragen
        if question.is_a? Gift::TrueFalseQuestion
          if question.answers[0][:value]
            q.question_options << QuestionOption.new(name: 'Wahr / true', correct: true)
            q.question_options << QuestionOption.new(name: 'Falsch / false', correct: false)
          else
            q.question_options << QuestionOption.new(name: 'Wahr / true', correct: false)
            q.question_options << QuestionOption.new(name: 'Falsch / false', correct: true)
          end
        elsif question.is_a? Gift::NumericQuestion
        elsif question.is_a?(Gift::ShortAnswerQuestion) || question.is_a?(Gift::EssayQuestion)
          q.add_setting "answers", TextSurvey::ONE_ANSWER
        else
          question.answers.each do |answer|
            # Korrektheit gilt, wenn das Gewicht >0 ist. Existiert kein Gewicht stimmt der ":correct"-Wert
            if answer[:weight].nil?
              correct = answer[:correct]
            else
              correct = answer[:weight]>0
            end
            q.question_options << QuestionOption.new(name: answer[:value], correct: correct)
          end
        end
        q.user = user
        q.tags = tags
        unless q.save
          errors << {"type" => "unknown_error", "text" => q.name}
        else
          successes << {"text" => q.name}
        end
      end
    rescue Exception
      # Fallback für alle nicht behandelten Fehler
      errors << {"type" => "file_error", "text" => "all"}
    end

    # Fehler-Array zurückgeben
    return errors, successes
  end
end
