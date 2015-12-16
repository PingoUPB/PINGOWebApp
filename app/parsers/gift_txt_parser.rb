class GiftTxtParser
  
  def export(questions)
    txt_content = ""
    questions.each do |question|
      # the gift format doesn't support order- nor category questions, so skip them
      if question.has_order_options?
        next
      elsif question.has_categories?
        next
      end

      # tags unter $CATEGORY vermerken
      unless question.tags.nil? || question.tags.empty?
        txt_content << "$CATEGORY: " + question.tags + "\r\n\n"
      else
        txt_content << "$CATEGORY: " + "\r\n\n"
      end

      txt_content << question.name

      if(question.has_options?)
        txt_content << "{\r\n"
        question.question_options.each do |option|
          if(option.correct)
            txt_content << "\t="
          else
            txt_content << "\t~"
          end
          txt_content << option.name
          txt_content << "\r\n"
        end
        txt_content << '}'
      elsif(question.type == "text")
        txt_content << '{}'
      elsif(question.type == "number")
        txt_content << '{#}'
      elsif(question.has_answer_pairs?)
        txt_content << "{\r\n"
        question.answer_pairs.where(correct: true).each do |pair|
          txt_content << "\t="
          txt_content << pair.answer1
          txt_content << ' -> '
          txt_content << pair.answer2
          txt_content << "\r\n"
        end
        txt_content << '}'
      end
      txt_content << "\r\n\n"
    end
    txt_content
  end

  def import (gift_file, user, tags)
    errors = []
    successes = []

    begin
      gift_string = gift_file.read

      gift_string.gsub! /\t/, ''
      gift_string = Converter.new.convert_to_utf8 gift_string

      categoriesWithLines = extractCategoriesWithLines(gift_string)

      for key in categoriesWithLines.keys 
        current_category = key
        current_questions_lines = categoriesWithLines[key]

        questions = extractQuestions(current_questions_lines)
        questions.each do |question|

          currentTitleArray = extractTitle(question)

          currentTitle = currentTitleArray[0]
          if currentTitle == "[[questionMalFormatted]]"
            next
          end
          question = currentTitleArray[1]

          q = Question.new
          questionTextAndAnswers = separateTextAndAnswers(question)

          # ignore descriptions
          if(questionTextAndAnswers[0] == "[[isDescription]]")
            errors << {"type" => "is_description", "text" => questionTextAndAnswers[1]}
            next
          end

          if isNumericalQuestion(questionTextAndAnswers[1])
            q = Question.new(type:"number").service
          elsif isTrueFalseQuestion(questionTextAndAnswers[1])
            q = Question.new(type:"single").service
            # Bei True/False-Fragen müssen die zwei Antwortoptionen explizit eingetragen werden.
            if statementIsTrue(questionTextAndAnswers[1])
              q.question_options << QuestionOption.new(name: 'Wahr / true', correct: true)
              q.question_options << QuestionOption.new(name: 'Falsch / false', correct: false)
            else
              q.question_options << QuestionOption.new(name: 'Wahr / true', correct: false)
              q.question_options << QuestionOption.new(name: 'Falsch / false', correct: true)
            end
          elsif isMatchingQuestion(questionTextAndAnswers[1])
            q = Question.new(type:"match").service
            answerPairs = extractAnswerPairs(questionTextAndAnswers[1])
            for pair in answerPairs
              q.answer_pairs << AnswerPair.new(answer1: pair[0].strip, 
                answer2: pair[1].strip, 
                correct: true)
            end
          elsif questionTextAndAnswers[1] == ""
            q = Question.new(type:"text").service
            q.add_setting "answers", TextSurvey::ONE_ANSWER
          elsif isShortAnswerQuestion(questionTextAndAnswers[1])
            q = Question.new(type:"text").service
            q.add_setting "answers", TextSurvey::ONE_ANSWER
          elsif onlyWrongWeightBasedAnswers(questionTextAndAnswers[1])
            errors << {"type" => "only_wrong_weight_based_answers", "text" => questionTextAndAnswers[0]}
            next
          elsif isSingleChoiceQuestion(questionTextAndAnswers[1])
            q = Question.new(type:"single").service
            answers = extractAnswers(questionTextAndAnswers[1].strip)
            for answer in answers
              q.question_options << QuestionOption.new(name: answer[0].strip, correct: answer[1])
            end
          elsif isMultipleChoiceQuestion(questionTextAndAnswers[1])
            q = Question.new(type:"multi").service
            answers = extractAnswers(questionTextAndAnswers[1].strip)
            for answer in answers
              q.question_options << QuestionOption.new(name: answer[0].strip, correct: answer[1])
            end
          else
            #Wenn der Fragetyp unbekannt ist wird die Frage nicht importiert sondern gemerkt
            errors << {"type" => "unknown_type", "text" => question.text}
            next
          end
          if(currentTitle == "")
            q.name = questionTextAndAnswers[0]
          else
            q.name = currentTitle + " - " + questionTextAndAnswers[0]
          end
          q.user = user

          if current_category == "__NO_CATEGORY__"
            q.tags = tags
          else
            q.tags = tags + "," + current_category
          end
          unless q.save
            errors << {"type" => "unknown_error", "text" => q.name}
          else
            successes << {"text" => q.name}
          end
        end
      end

        
    rescue Exception
      # Fallback für alle nicht behandelten Fehler
      errors << {"type" => "file_error", "text" => "all"}
    end

    # Fehler-Array zurückgeben
    return errors, successes
  end

  def isTrueFalseQuestion(questionAsString)
    return questionAsString == "T" ||
      questionAsString == "TRUE" ||
      questionAsString.starts_with?("T#") ||
      questionAsString.starts_with?("TRUE#") ||
      questionAsString == "F" || 
      questionAsString == "FALSE" ||
      questionAsString.starts_with?("F#") || 
      questionAsString.starts_with?("FALSE#")
  end

   def statementIsTrue(questionAsString)
    if(questionAsString == "T" ||
      questionAsString == "TRUE" ||
      questionAsString.starts_with?("T#") ||
      questionAsString.starts_with?("TRUE#")) 
      return true
    else
      return false
    end
  end

  def isNumericalQuestion(questionAsString)
    return questionAsString.starts_with?("#")
  end

  def isMatchingQuestion(questionAsString)
    firstIndex = getIndexOfFirstUnescapedCharacter("=", questionAsString, 0)
    if(firstIndex == -1)
      return false
    else
      if questionAsString.match(/=.{1,}->.{1,}/) == nil
        return false
      else
        return true
      end
    end
  end

  def extractAnswerPairs(answerString)
    pairs = Array.new
    pairIndex = 0
    indeces = getIndecesOfAllUnescapedCharacters("=", answerString)
    for i in 0..(indeces.length-1)
      if(i == indeces.length-1)
        pairs[pairIndex] = answerString[indeces[i]+1..(answerString.length-1)].split('->')
      else
        pairs[pairIndex] = answerString[indeces[i]+1..indeces[i+1]-1].split('->')
        pairIndex += 1
      end
    end
    return pairs
  end

  # short-answer-question have only correct answers
  def isShortAnswerQuestion(answerAsString)
    firstIndex = getIndexOfFirstUnescapedCharacter("~", answerAsString, 0)
    if(firstIndex == -1)
      return true
    else
      return false
    end
  end

  # singleChoiceQuestions have just one correct answer
  def isSingleChoiceQuestion(answerAsString)
    firstIndex = getIndexOfFirstUnescapedCharacter("=", answerAsString, 0)
    secondIndex = getIndexOfFirstUnescapedCharacter("=", answerAsString, firstIndex+1)
    if(secondIndex != -1)
      return false
    else
      return true
    end
  end

  def onlyWrongWeightBasedAnswers(answerAsString)
    firstIndex = getIndexOfFirstUnescapedCharacter("=", answerAsString, 0)
    if(firstIndex == -1)
      index = getIndexOfFirstUnescapedCharacter("~", answerAsString, 0)
      if(index == -1)
        return false
      else
        return true
      end
    else
      return false
    end
  end

  # multipleChoiceQuestions have more than one correct answers
  def isMultipleChoiceQuestion(answerAsString)
    firstIndex = getIndexOfFirstUnescapedCharacter("=", answerAsString, 0)
    secondIndex = getIndexOfFirstUnescapedCharacter("=", answerAsString, firstIndex+1)
    if(secondIndex == -1)
      return false
    else
      return true
    end
  end

  # returns an array of arrays.
  # every array consists of an answer (string)
  # and a boolean value (correctness of the answer)
  def extractAnswers(answersAsString)
    answers = Array.new
    answerIndex = 0
    indeces = getIndecesOfAllUnescapedCharacters("=", answersAsString)
    indeces = indeces.concat(getIndecesOfAllUnescapedCharacters("~", answersAsString))
    indeces.sort!
    for i in 0..(indeces.length-1)
      if(i == indeces.length-1)
        currentString = answersAsString[indeces[i]..(answersAsString.length-1)]
      else
        currentString = answersAsString[indeces[i]..indeces[i+1]-1]
      end

      if(currentString.starts_with?('='))
        correct = true
      end

      if(currentString.starts_with?('~'))
        correct = false
      end

      currentString = currentString[1..(currentString.length-1)]
      currentString.strip!

      # ignore feedback to answers
      index = getIndexOfFirstUnescapedCharacter("#", currentString, 0)
      if(index == -1)
        answers[answerIndex] = [currentString, correct]
      else
        answers[answerIndex] = [currentString[0..index-1], correct]
      end

      #ignore percentage weights of answers
      index = getIndexOfFirstUnescapedCharacter("%", answers[answerIndex][0], 0)
      if(index != -1)
        secondIndex = getIndexOfFirstUnescapedCharacter("%",answers[answerIndex][0], index+1)
        if(secondIndex != -1)
          if(index == 0)
            answers[answerIndex][0] = answers[answerIndex][0][secondIndex+1..answers[answerIndex][0].length-1]
          else
            answers[answerIndex][0] = answers[answerIndex][0][0..index-1]
            + answers[answerIndex][0][secondIndex+1..answers[answerIndex][0].length-1]
          end
        end
      end

      answerIndex += 1
    end

    return answers
  end

  # Extracts the categories in the given string into a hash
  def extractCategoriesWithLines(utf8string)
    categoriesWithLines = Hash.new
    current_category = "__NO_CATEGORY__"
    categoriesWithLines[current_category] = Array.new

    linesAsStrings = utf8string.split(/\r?\n/)
    linesAsStrings.each do |line|
      line.strip!
      if(line.start_with?("$CATEGORY:"))
        if line.length > 11
          current_category = line[11..line.length]
          current_category.strip!
          categoriesWithLines[current_category] = Array.new
        else
          current_category = "__NO_CATEGORY__"
        end
      else
        categoriesWithLines[current_category] << line
      end
    end

    return categoriesWithLines
  end

  # Extracts the questions in the given lines int an array
  def extractQuestions(lines) 
    questions = Array.new
    questionIndex = 0

    lines.each do |line|

      line.strip!

      #ignore comments
      if(line.start_with?("//"))
        next
      end

      #separate at blank lines
      if(/^\s{1,}$/.match(line) || line.length == 0)
        questionIndex += 1
      else
        if questions[questionIndex].nil?
          questions[questionIndex] = ""
        end
        questions[questionIndex] += " " + line
        questions[questionIndex].strip!
        questions[questionIndex].gsub! /\s{2,}/, ' '
      end
    end

    questions.compact!
    return questions
  end

  # Returns an array with 2 components!
  # Extracts a title if there is one ("" otherwise; 
  # "[[questionMalFormatted]]" if mal formatted) as the first component.
  # The second components has the argument without the title section
  def extractTitle(questionAsString)
    firstIndex = getIndexOfFirstUnescapedCharacter("::", questionAsString, 0)
    if(-1 == firstIndex)
      return ["",questionAsString]
    else
      secondIndex = getIndexOfFirstUnescapedCharacter("::", questionAsString, firstIndex+2)
      if(-1 == secondIndex)
        return ["[[questionMalFormatted]]", ""]
      else
        # there are more unescaped ::
        if(getIndexOfFirstUnescapedCharacter("::", questionAsString, secondIndex+2) != -1)
          return ["[[questionMalFormatted]]", ""]
        else
          if(firstIndex != 0)
            return [questionAsString[firstIndex + 2 .. secondIndex-1],
              questionAsString[0..firstIndex-1] + questionAsString[secondIndex+2..questionAsString.length-1].strip]
          else
            [questionAsString[firstIndex + 2 .. secondIndex-1],
              questionAsString[secondIndex+2..questionAsString.length-1].strip]
          end
        end
      end
    end
  end

  def getIndexOfFirstUnescapedCharacter(characterAsString, questionAsString, startIndex)
    charLength = characterAsString.length
    indecesOfCharacter = (startIndex ... questionAsString.length).find_all { |i| questionAsString[i,charLength] == characterAsString }
    for index in indecesOfCharacter
      if(0 == index)
        return index
      elsif(questionAsString[index-1] == "\\")
        next
      else
        return index
      end
    end
    return -1
  end

  def getIndecesOfAllUnescapedCharacters(characterAsString, questionAsString)
    charLength = characterAsString.length
    indecesOfCharacter = (0..questionAsString.length-1).find_all { |i| questionAsString[i,charLength] == characterAsString }
    indecesToBeDeleted = Array.new
    for index in indecesOfCharacter
      if(index == 0)
        next
      end
      if(questionAsString[index-1] == '\\')
        indecesToBeDeleted << index
      end
    end
    indecesOfCharacter = indecesOfCharacter - indecesToBeDeleted
    return indecesOfCharacter
  end

  # Returns an array with two components.
  # The first component is the question text (a string).
  # The scond component is are the answers (a string)
  def separateTextAndAnswers(questionAsString)
    # ignore special formats
    questionAsString = cutOutFormats(questionAsString)

    firstIndex = getIndexOfFirstUnescapedCharacter("{", questionAsString, 0)
    if(-1 == firstIndex)
      return ["[[isDescription]]",questionAsString]
    else
      secondIndex = getIndexOfFirstUnescapedCharacter("}", questionAsString, firstIndex+1)
      if(-1 == secondIndex)
        return ["[[questionMalFormatted]]", "NOSECONDINDEX"]
      else
        if(getIndexOfFirstUnescapedCharacter("{", questionAsString, secondIndex+1) != -1 ||
          getIndexOfFirstUnescapedCharacter("}", questionAsString, secondIndex+1)) != -1
          return ["[[questionMalFormatted]]", "TOOMANYUNESCAPED"]
        else
          if(firstIndex == 0)
            return ["... " + questionAsString[secondIndex+1..questionAsString.length-1].strip,
              questionAsString[firstIndex + 1 .. secondIndex-1].strip]
          elsif(secondIndex == questionAsString.length-1)
            return [questionAsString[0..firstIndex-1].strip, 
              questionAsString[firstIndex+1 .. secondIndex-1].strip]
          else
            return [questionAsString[0..firstIndex-1].strip + " ... " + questionAsString[secondIndex+1..questionAsString.length-1].strip,
              questionAsString[firstIndex+1 .. secondIndex-1].strip]
          end
        end
      end
    end
  end

  def cutOutFormats(questionAsString)
    questionAsString.gsub! '[html]', ''
    questionAsString.gsub! '[moodle]', ''
    questionAsString.gsub! '[plain]', ''
    questionAsString.gsub! '[markdown]', ''
    return questionAsString
  end

end
