class OrderOption
  include Mongoid::Document

  embedded_in :question
  embedded_in :survey
  field :name, type: String
  field :position, type: Integer, default: nil
  field :description, type: String
  field :votes, type: String #Actually we'd like to have an array of integers here, 
  # where every entry stands for the votes for this option at this (entry's) postion.
  # But since there's is no Mongoid field type "IntegerArray", we do it via a String,
  # e.g. "5,8,0,0,5,3"

  validates_presence_of :name
  validates_presence_of :position
  validates_format_of :name, :without => / - /

  def vote_up(position)
    votesArray = self.votes.split(",")
    votesArray[position] = (Integer(votesArray[position]) + 1).to_s
  end
   
  def vote_down
    votesArray = self.votes.split(",")
    votesArray[position] = (Integer(votesArray[position]) - 1).to_s
  end

end