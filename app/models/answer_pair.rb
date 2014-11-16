class AnswerPair
  include Mongoid::Document

  embedded_in :question
  field :answer1, type: String
  field :answer2, type: String

  validates_presence_of :answer1
  validates_presence_of :answer2
end
