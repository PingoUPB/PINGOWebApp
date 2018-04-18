class AikenParser

  def export(questions)
    result = ""
    # Über alle Fragen iterieren
    questions.each_with_index do |question, index|
      result << question.name + "\r\n"
      option_index = "A"

      # Über alle Optionen iterieren und die korrekten Optionen merken
      correct_options = []
      question.question_options.each do |option|
        result << option_index + ") " + option.name + "\r\n"
        if option.correct
          correct_options << option_index
        end
        option_index = option_index.next
      end
      # Fragen sind geschrieben - nun die Antworten
      result << "ANSWER: "

      #Korrekte Optionen aneinanderreihen
      option_string = correct_options.join(",")

      # Wenn es korrekte Optionen gibt diese an den String hängen
      result << option_string unless option_string.blank?

      # Falls noch Fragen folgen wird eine leere Zeile eingefügt
      unless index == questions.size - 1
        result << "\r\n\r\n"
      end
    end

    result
  end

  def import(aiken_file, user, tags)
    # Über alle Zeilen iterieren
    errors = []
    successes = []
    begin

      # Vorgehen bei Fehler:
      # errors << {"type" => "unknown_error", "text" => current_question.name}
      # Dann evtl. question_error = true, dies überspringt den Rest der Frage

      question_error = false;
      current_question = nil
      option_hash = Hash.new
      question_type = nil
      question_count = 0
      aiken_file.read.each_line do |line|
        line = Converter.new.convert_to_utf8 line

        unless /(\d+\)\s|\w)/.match(line)
          # Leerzeilen überspringen
          next
        end

        if line.starts_with?("Diff", "AACSB", "CASE", "Objective")
          # Nicht benötigte Pearson-Informationen überspringen
          next
        end

        # Herausfinden, welchen Typ von Zeile (Frage, Antwortmöglichkeiten, korrekte Antworten) wir behandeln
        # if line[1] == '.' || line[1] == ')' && line[2] == " " && line[0] == line[0].upcase
        if /^[A-Z](\)|\.).+/.match(line) && !question_error && question_type != "pearson_cloze"
          #linetype = 'option'
          question_option = QuestionOption.new
          question_option.name = line[3..-1].chomp
          current_question.question_options << question_option
          option_hash[line[0]] = question_option
        elsif line.starts_with?("ANSWER:", "Answer:") && !question_error && question_type != "pearson_cloze"
          #linetype = 'answer'
          # Nur die reinen Antworten als Array entnehmen

          answers = line.split(" ")[1]
          if answers.nil?
            # Keine korrekten Antworten angegeben
            errors << {"type" => "aiken_missing_answers", "text" => current_question.name}
            question_error = true
          else
            answers = answers.split(",")
            if answers.size > 1
              current_question.type = "multi"
            else
              current_question.type = "single"
            end
            if /(FALSE|TRUE)/.match(answers[0])
              # Pearson-True/False-Frage erkannt
              current_question.question_options << QuestionOption.new(name: "TRUE", correct: answers[0] == "TRUE")
              current_question.question_options << QuestionOption.new(name: "FALSE", correct: answers[0] == "FALSE")
            elsif /[a-z]/.match(answers[0])
              # Pearson-Freitext-Frage erkannt
              name_tmp = current_question.name
              current_question = Question.new(type:"text").service
              current_question.name = name_tmp
              current_question.add_setting "answers", TextSurvey::ONE_ANSWER
            else
              answers.each do |answer|
                option_hash[answer].correct = true
              end
            end
          end
          current_question.user = user
          
          # current_question.tags = tags   ### FIXME
          
          unless current_question.save
            errors << {"type" => "unknown_error", "text" => current_question.name}
          else
            successes << {"text" => current_question.name}
          end
        else
          question_error = false
          question_type = nil
          #linetype = 'question'
          current_question = Question.new
          current_question.name = line.chomp
          current_question.name = remove_leading_numbers current_question.name

          # Abfangen von Lückentext-Fragen aus Pearson
          if line.include? "__"
            question_type = "pearson_cloze"
            current_question = Question.new(type:"text").service
            current_question.name = remove_leading_numbers line.chomp
            current_question.add_setting "answers", TextSurvey::ONE_ANSWER
            current_question.user = user
            current_question.tags_array = tags
            current_question.save
          end
          question_count = question_count + 1
        end
      end
    rescue Exception
      # Fallback für alle nicht behandelten Fehler
      errors << {"type" => "file_error", "text" => "all"}
    end
    return errors, successes
  end

  protected
  def remove_leading_numbers(s)
    if /\d+\)\s/.match(s)
      # Wir haben eine Pearson-Frage mit voranstehender Zahl, diese schneiden wir ab
      s = s.split(") ")[1]
    else
      s
    end
  end
end