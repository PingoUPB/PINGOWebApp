require "rexml/document"
class MoodleXmlParser 
  include REXML
  def export(questions)
    root = Element.new "quiz"

    # Über Fragen iterieren
    questions.each do |question|

      # moodle xml doesn't support order- nor category questions, so we skip them
      if question.type == "order"
        next
      elsif question.type == "category"
        next
      end
      # Grundbaum der Frage aufbauen
      question_node = root.add_element "question"
      name_node = question_node.add_element "name"
      (name_node.add_element "text").text = question.name
      question_text_node = question_node.add_element "questiontext"
      question_text_node.attributes["format"] = "html"
      (question_text_node.add_element "text").text = question.name

      # tags anlegen, falls sie existieren
      unless question.tags.nil? || question.tags.empty?
        tags_node = question_node.add_element "tags"
        question.tags.split(',').each do |tag|
          tag_node = tags_node.add_element "tag"
          (tag_node.add_element "text").text = tag
        end
      end

      # Question Options hinzufügen für single- und multi-choice fragen
      if question.type == "multi" || question.type == "single"
        question_node.attributes["type"] = "multichoice"

        question.question_options.each do |option|
          answer_node = question_node.add_element "answer"
          (answer_node.add_element "text").text = option.name
          if option.correct
            answer_node.attributes["fraction"] = "100"
          else
            answer_node.attributes["fraction"] = "0"
          end
        end

        if question.type == "single"
          (question_node.add_element "single").text = "true"
        else
          (question_node.add_element "single").text = "false"
        end
      end

      # Bei Number-Fragen wird 0 als Standardantwort gesetzt
      if question.type == "number"
        question_node.attributes["type"] = "numerical"
        answer_node = question_node.add_element "answer"
        (answer_node.add_element "text").text = "0"
        answer_node.attributes["fraction"] = "100"
      end

      # Bei Freitext-Fragen wird eine leere Antwortmöglichkeit hinzugefügt
      if question.type == "text"
        question_node.attributes["type"] = "shortanswer"
        answer_node = question_node.add_element "answer"
        (answer_node.add_element "text").text = " "
        answer_node.attributes["fraction"] = "100"
      end

      # Bei Multiple-Choice-Fragen wird mit "a, b, c" etc. Numeriert
      if question.type == "single" || question.type == "multi"
        (question_node.add_element "answernumbering").text = "abc"
      end

      if question.type == "match"
        question_node.attributes["type"] = "match"
        question.answer_pairs.where(correct: true).each do |pair|
          subquestion_node = question_node.add_element "subquestion"
          (subquestion_node.add_element "text").text = pair.answer1
          answer_node = subquestion_node.add_element "answer"
          (answer_node.add_element "text").text = pair.answer2
        end
        (question_node.add_element "shuffleanswers").text = "true"
      end

    end

    s = ""
    formatter = Formatters::Pretty.new(2)
    formatter.compact = true
    s = "<?xml version=\"1.0\" ?>\r\n" << formatter.write(root, s)
    s.gsub!("\n", "\r\n")
    s
  end

  def import (xml_file, user, tags)
    errors = []
    successes = []
    begin
    xml_string = xml_file.read
    xml_string = Converter.new.convert_to_utf8 xml_string
    doc = Document.new xml_string

    # Über Question-Elemente iterieren
    doc.elements.each("quiz/question") do |element|
      question_type = element.attributes["type"]
      q = Question.new

      # Zunächst den Questiontype feststellen
      if question_type == 'multichoice' || question_type == 'truefalse'
        if element.elements["single"].text || question_type == 'truefalse'
          q = Question.new(type:"single").service
        else
          q = Question.new(type:"multi").service
        end
      elsif question_type == 'shortanswer' || question_type == 'essay'
        q = Question.new(type:"text").service
      elsif question_type == 'numerical'
        q = Question.new(type:"number").service
      elsif question_type == 'match'
        q = Question.new(type:"match").service
      elsif question_type == 'cloze' || question_type == 'description'
        # Nicht unterstützte Fragen abfangen
        errors << {"type" => "unsupported_type", "text" => element.elements["questiontext/text"].text}
        next
      else
        # Unbekannte Fragetypen abfangen
        errors << {"type" => "unknown_type", "text" => element.elements["questiontext/text"].text}
        next
      end

      # Fragetext setzen
      q.name = element.elements["questiontext/text"].text

      # Tags dieser spezifischen Frage auslesen und setzen
      tags_string = ""
      element.elements.each("tags/tag") do |tag_element|
        if tags_string == ""
          tags_string = tag_element.elements["text"].text
        else
          tags_string << "," + tag_element.elements["text"].text
        end
      end
      unless tags_string == ""
        q.tags = tags_string
      end

      # Über Antwortmöglichkeiten iterieren, bei Number-Fragen oder Freitext-Fragen werden die korrekten Antworten ignoriert
      if question_type == "numerical" || question_type == "essay" || question_type == "shortanswer"
      elsif question_type == "match"
        element.elements.each("subquestion") do |pair|
          answer1 = pair.elements["text"].text
          answer2 = pair.elements["answer"].elements["text"].text
          q.answer_pairs << AnswerPair.new(answer1: answer1, answer2: answer2)
        end
      else
        element.elements.each("answer") do |answer|
          correct = Integer(answer.attributes["fraction"]) > 0 ? true : false
          text = answer.elements["text"].text
          q.question_options << QuestionOption.new(name: text, correct: correct)
        end
      end

      # Wenn Textfrage dann genau eine Antwort, Moodle unterstützt keine Begrenzung
      if q.type == "text"
        q.add_setting "answers", TextSurvey::ONE_ANSWER
      end
      q.user = user

      # Hinzufügen von tags, die für alle importierten Fragen gelten sollen
      unless q.tags.nil? || q.tags.empty?
        q.tags = q.tags + "," + tags
      else
        q.tags = tags
      end

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
    return errors, successes
  end

end