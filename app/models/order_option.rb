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

  # TODO: Why are the messages not working?
  validates_presence_of :name, message: ": Name of option can't be blank."
  validates_presence_of :position, message: ": Positions of options are missing."
  validates_format_of :name, :without => / - /, message: ": No ' - ' inside option names."

  def vote_up(position)
    votesArray = self.votes.split(",")
    votesArray[position-1] = Integer(votesArray[position-1]) + 1
    self.votes = votesArray.to_s
    self.votes.gsub! '"', ''
    self.votes.gsub! '[', ''
    self.votes.gsub! ']', ''
    self.votes.gsub! ' ', ''
    self.save!
  end
   
  def vote_down(position)
    votesArray = self.votes.split(",")
    votesArray[position-1] = Integer(votesArray[position-1]) - 1
    self.votes = votesArray.to_s
    self.votes.gsub! '"', ''
    self.votes.gsub! '[', ''
    self.votes.gsub! ']', ''
    self.votes.gsub! ' ', ''
    self.save!
  end

end