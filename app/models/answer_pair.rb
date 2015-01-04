class AnswerPair
  include Mongoid::Document

  embedded_in :question
  embedded_in :survey
  field :answer1, type: String
  field :answer2, type: String
  field :votes, type: Integer, default: 0
  field :description, type: String
  field :correct, type: Boolean, default: true

  validates_presence_of :answer1
  validates_presence_of :answer2

  def self.buildnew(answer1 = "answer1", answer2 = "answer2", correct = false)
    ap = AnswerPair.new
  	ap.answer1 = answer1
  	ap.answer2 = answer2
  	ap.correct = correct
    return ap
  end

  def vote_up
    self.inc(:votes, 1)
  end
   
  def vote_down
    self.inc(:votes, -1)
  end

  def correct?
    self.correct
  end
end
