require 'spec_helper'

describe MultipleChoiceQuestion do
  it "keeps a single correct answer when transforming" do
    question = create_multiple_choice_question
    question.question_options = [QuestionOption.new(name: "Foo", correct: true), QuestionOption.new(name: "Bar", correct: false)]
    question.save!

    question.transform
    correct_answers = question.question_options.select{|o| o.correct }
    correct_answers.size.should eq(1)
    correct_answers.first.name.should eq("Foo")
  end

  it "sets multiple correct answers to false when transforming" do
    question = create_multiple_choice_question
    question.question_options = [QuestionOption.new(name: "Foo", correct: true), QuestionOption.new(name: "Bar", correct: true)]
    question.save!
    
    question.transform
    question.question_options.select{|o| o.correct }.size.should eq(0)
  end
end
