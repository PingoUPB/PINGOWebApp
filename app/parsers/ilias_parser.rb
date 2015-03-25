require "rexml/document"
class IliasParser
  include REXML

  def export(questions)
    root = Element.new "questestinterop"

    # Über Fragen iterieren
    questions.each do |question|
      question_node = root.add_element "item"

      # Elemente der Frage hinzufügen und teilweise für später merken
      question_node.add_element "qticomment"
      qtimetadata_node = (question_node.add_element "itemmetadata").add_element "qtimetadata"

      # Den Ilias-Typ bestimmen
      if question.type == "single"
        ilias_question_type = "SINGLE CHOICE QUESTION"
      elsif question.type == "multi"
        ilias_question_type = "MULTIPLE CHOICE QUESTION"
      elsif question.type == "number"
        ilias_question_type = "NUMERIC QUESTION"
      elsif question.type == "text"
        ilias_question_type = "TEXT QUESTION"
      elsif question.type == "match"
        ilias_question_type = "MATCHING QUESTION"
      end

      # Metadaten einfügen
      arr1 = ["ILIAS_VERSION", "QUESTIONTYPE", "AUTHOR", "thumb_size"]
      arr2 = ["4.3.4 2013-07-10", ilias_question_type, "PINGO Export Tool", ""]
      if question.type == "text"
        arr1 = arr1 + ["textrating", "matchcondition", "termscoring", "termrelation", "specificfeedback"]
        arr2 = arr2 + ["ci", "", "a:0:{}", "non", "non"]
      end
      create_metadata(qtimetadata_node, arr1, arr2)

      # Attribute der Frage hinzufügen
      question_node.attributes["title"] = question.name
      question_node.attributes["maxattempts"] = "1"

      # Hinzufügen der Antworten
      presentation_node = question_node.add_element "presentation"
      presentation_node.attributes["label"] = question.name


      flow_node = presentation_node.add_element "flow"
      mattext_node = (flow_node.add_element "material").add_element "mattext"
      mattext_node.attributes["texttype"] = "text/xhtml"
      mattext_node.text = question.name

      if question.type.in? ["multi", "single"]
        response_lid_node = flow_node.add_element "response_lid"
        render_choice_node = response_lid_node.add_element "render_choice"
        if question.type == "multi"
          response_lid_node.attributes["rcardinality"] = "Multiple"
        else
          response_lid_node.attributes["rcardinality"] = "Single"
        end
      elsif question.type == "number"
        response_lid_node = flow_node.add_element "response_num"
        response_lid_node.attributes["ident"]="NUM"
        response_lid_node.attributes["rcardinality"]="Single"
        response_lid_node.attributes["numtype"]="Decimal"
        render_fib_node = response_lid_node.add_element "render_fib"
        render_fib_node.attributes["fibtype"] = "Decimal"
        render_fib_node.attributes["maxchars"] = "10"
      elsif question.type == "text"

      end

      resprocessing_node = question_node.add_element "resprocessing"
      decvar_node = (resprocessing_node.add_element "outcomes").add_element "decvar"

      if question.type.in? ["multi", "single"]
        ident = 0
        question.question_options.each do |question_option|
          response_label_node = render_choice_node.add_element "response_label"
          response_label_node.attributes["ident"] = ident
          mattext_node = (response_label_node.add_element "material").add_element "mattext"
          mattext_node.attributes["texttype"] = "text/plain"
          mattext_node.text = question_option.name

          # Für korrekte Antwortmöglichkeiten eine Bepunktung >0 einfügen
          respcondition_node = resprocessing_node.add_element "respcondition"
          respcondition_node.attributes["continue"] = "Yes"
          (respcondition_node.add_element "displayfeedback").attributes["feedbacktype"] = "Response"
          ((respcondition_node.add_element "conditionvar").add_element "varequal").text = ident
          setvar_node = respcondition_node.add_element "setvar"
          setvar_node.attributes["action"] = "Add"

          if (question_option.correct)
            setvar_node.text = "1"
          else
            setvar_node.text = "0"
          end

          ident = ident + 1
        end
      elsif question.type == "text"
        resprocessing_node.attributes["scoremodel"] = "HumanRater"
        decvar_node.attributes["varname"] = "WritingScore"
        decvar_node.attributes["vartype"] = "Integer"
        decvar_node.attributes["minvalue"] = "0"
        decvar_node.attributes["maxvalue"] = "3"
        (((resprocessing_node.add_element "respcondition").add_element "conditionvar").add_element "other").text = "tutor_rated"
      elsif question.type == "number"
        respcondition_node = resprocessing_node.add_element "respcondition"
        setvar_node = respcondition_node.add_element "setvar"
        setvar_node.text = "3"
        setvar_node.attributes["action"] = "Add"
      elsif question.type == "match"
        question.answer_pairs.where(correct: true).each do |pair|
        end
      end


    end

    s = ""
    formatter = Formatters::Default.new
    s = "<?xml version=\"1.0\" ?><!DOCTYPE questestinterop SYSTEM \"ims_qtiasiv1p2p1.dtd\">" + formatter.write(root, s)
    s
  end

  def import (xml_file, user, tags)
    errors = []
    successes = []
    begin
      xml_string = xml_file.read
      xml_string = Converter.new.convert_to_utf8 xml_string
      doc = Document.new xml_string

      question_type = nil

      # Über Question-Elemente iterieren
      doc.elements.each("questestinterop/item") do |element|
        element.elements.each("itemmetadata/qtimetadata/qtimetadatafield") do |metadatafield|
          if metadatafield.elements["fieldlabel"].text == "QUESTIONTYPE"
            question_type = metadatafield.elements["fieldentry"].text
          end
        end

        # Bekannte aber nicht unterstützte Formate filtern
        if question_type.in? ['assOrderingHorizontal', 'ORDERING QUESTION', 'assFileUpload', 'assFlashQuestion', 'IMAGE MAP QUESTION', 'assErrorText', 'CLOZE QUESTION']
          errors << {"type" => "unsupported_type", "text" => element.elements["presentation/flow/material/mattext"].text.gsub(/<\S*>/,"")}
          next
        end

        # Erstellung einer entsprechenden Frage
        if question_type == 'SINGLE CHOICE QUESTION'
          q = Question.new(type:"single").service
        elsif question_type == 'MULTIPLE CHOICE QUESTION'
          q = Question.new(type:"multi").service
        elsif question_type == 'MATCHING QUESTION'
          q = Question.new(type:"match").service
        elsif question_type == 'NUMERIC QUESTION'
          q = Question.new(type:"number").service
        elsif question_type.in? ['TEXT QUESTION', 'TEXTSUBSET QUESTION']
          q = Question.new(type:"text").service
          q.add_setting "answers", TextSurvey::MULTI_ANSWERS
        else
          errors << {"type" => "unknown_type", "text" => element.elements["presentation/flow/material/mattext"].text.gsub(/<\S*>/,"")}
          next
        end

        # Fragetext setzen
        q.name = element.elements["presentation/flow/material/mattext"].text.gsub(/<\S*>/,"")

        option_hash = Hash.new

        # Antwortmöglichkeiten entnehmen und Identifier als Hash merken
        if question_type.in? ['SINGLE CHOICE QUESTION', 'MULTIPLE CHOICE QUESTION']
          element.elements.each("presentation/flow/response_lid/render_choice/response_label") do |response_label|
            option = QuestionOption.new(name:response_label.elements["material/mattext"].text)
            response_id = response_label.attributes["ident"]
            option_hash[response_id] = option
            q.question_options << option
          end

          # Korrekte Antwortmöglichkeiten setzen
          unless option_hash.empty?
            element.elements.each("resprocessing/respcondition") do |respcondition|
              if respcondition.elements["conditionvar/varequal"].nil?
                next
              end
              text = respcondition.elements["conditionvar/varequal"].text
              option = option_hash[text]
              if respcondition.elements["setvar"].text.to_i > 0
                option.correct = true
              end
            end
          end
        elsif question_type == 'MATCHING QUESTION'
          element.elements.each(#...)
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
    return errors, successes
  end

  protected
  def create_metadata(parent, labels, entries)
    current = 0
    labels.each do |label|
      metafield = parent.add_element "qtimetadatafield"
      (metafield.add_element "fieldlabel").text = label
      (metafield.add_element "fieldentry").text = entries[current]
      current = current + 1
    end
  end
end