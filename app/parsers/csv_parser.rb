require "csv"
require 'logger'
@@log = Logger.new('log.txt')
@@log.debug "Log file created"
class CsvParser

  def export(questions)
    csv_string = CSV.generate(quote_char: '"') do |csv|
      # CSV-Header einfügen
      csv << ["Type", "Question", "Tags", "Correct", "Answers"]
      questions.each do |question|
        current = [question.type, question.name, ""]

        # Hinzufügen von tags, falls vorhanden
        unless question.tags.nil? || question.tags.empty?
          question.tags.split(",").each do |tag|
            if current[2]==""
              current[2] = tag
            else
              current[2] = current[2] + ";" + tag
            end
          end
        end

        current << ""

        @@log.debug current.to_s

        correct_options = []
        option_number = 1
        if question.type == "single" || question.type == "multi"
          question.question_options.each do |option|
            current << option.name
            correct_options << option_number if option.correct  # Nummern der korrekten Antworten merken   
            option_number = option_number + 1
          end
        elsif question.type == 'text'
          answer_type = question.service.settings["answers"]
          if answer_type == TextSurvey::ONE_ANSWER
            correct_options << '1'
          elsif answer_type == TextSurvey::THREE_ANSWERS
            correct_options << '3'
          end
        elsif question.type == 'match'
          question.answer_pairs.where(correct: true).each do |pair|
            current << pair.answer1 + ' - ' + pair.answer2
          end
        elsif question.type == 'order'
          question.order_options.each do |option|
            current << option.position.to_s + ") " + option.name
          end
        elsif question.type == 'category'
          question.categories.each do |category|
            current << category.name + "|||" + category.sub_words
          end
        end
        unless correct_options.empty?
          correct_options = correct_options.join ";"
          current[3] = correct_options # Korrekte Antworten anhängen
        end
        csv << current
      end
    end
  end

  def import(csv_file, user, tags, separator = ",")
    errors = []
    successes = []

    begin
      csv_string = csv_file.read
      csv_string = Converter.new.convert_to_utf8 csv_string

      row = 1
      begin
        CSV.parse(csv_string, col_sep: separator) do |question|
          if question[0] == "Type" && question[1] == "Question"
            # Header überspringen
            next
          end

          unless Question.question_types.include?(question[0])
            errors << {"type" => "unknown_type", "text" => question[1]} # Zeilennummer mit Fehler merken
            row = row + 1
            next
          else
            #Frage erstellen
            q = Question.new(type:question[0], name:question[1]).service

            # Hinzufügen von tags, die nur für diese Frage gelten sollen
            unless question[2].nil? || question[2].empty?
              question[2].split(";").each do |tag|
                unless q.tags.nil? || q.tags.empty?
                  q.tags = q.tags + "," + tag
                else
                  q.tags = tag
                end
              end
            end

            # Hinzufügen von tags, die für alle importierten Fragen gelten sollen
            unless q.tags.nil? || q.tags.empty?
              q.tags = q.tags + "," + tags
            else
              q.tags = tags
            end

            # Korrekte Antwortmöglichkeiten extrahieren
            if question[0] == "single" || question[0] == "text"
              answers = [question[3]]
            elsif question[0] == "multi" || question[0] == "match"
              answers =  question[3].split(";")
            end

            if question[0] == "match"
              question.drop(4).each do |pair| # Die ersten vier Elemente beinhalten keine Antworten
                q.answer_pairs << AnswerPair.new(answer1: pair.split(' - ')[0], answer2: pair.split(' - ')[1])
              end
            elsif question[0] == "order"
              question.drop(4).each do |option|
                q.order_options << OrderOption.new(name: option.split(') ')[1], position: option.split(') ')[0])
              end
            elsif question[0] == "category"
              question.drop(4).each do |categoryAndSubWords|
                currentCategory = categoryAndSubWords.split("|||")[0]
                currentSubWords = categoryAndSubWords.split("|||")[1]
                q.categories << Category.new(name: currentCategory, sub_words: currentSubWords)
                currentSubWords.split(";").each do |sub_word|
                  q.sub_words << SubWord.new(name: sub_word, category: currentCategory)
                end
              end
            else
              question.drop(4).each do |option| # Die ersten vier Elemente beinhalten keine Antworten
                unless option.nil? || option == ""
                  q.question_options << QuestionOption.new(name: option) # QuestionOptions sind in der Frage eingebettet und werden mitgesichert
                end
              end
            end

            #Korrekte Frageoptionen setzen oder bei Textfragen die korrekten Settings setzen
            if q.type == "text"
              if answers.first == '1'
                q.add_setting "answers", TextSurvey::ONE_ANSWER
              elsif answers.first == '3'
                q.add_setting "answers", TextSurvey::THREE_ANSWERS
              elsif answers.first.blank?
                q.add_setting "answers", TextSurvey::MULTI_ANSWERS
              end
            else
              if answers
                answers.each do |answer|
                  q.question_options[answer.to_i-1].correct = true
                end
              end
            end

            q.user = user
            unless q.save # true/false je nachdem ob erfolgreich gesichert wurde
              errors << {"type" => "unknown_error", "text" => q.name}
            else
              successes << {"text" => q.name}
            end
          end
          row = row + 1 # Fertig mit der Zeile
        end
          # Falls etwas mit der CSV nicht stimmt
      rescue CSV::MalformedCSVError
        error_info = "Zeile/Row #{row}"
        begin 
          error_info += " - " + csv_string.split("\n")[row].split(separator)[1]
        rescue; end
          errors << {"type" => "unknown_error", "text" => error_info}
      end
    rescue Exception
      # Fallback für alle nicht behandelten Fehler
      errors << {"type" => "file_error", "text" => "all"}
    end
    return errors, successes # Rückgabewert ist das Array mit fehlerhaften Zeilen
  end
end