class SubWord
  include Mongoid::Document

  embedded_in :question
  embedded_in :survey
  field :name, type: String
  field :category, type: String
  field :description, type: String
  field :votes, type: Hash, default: Hash.new
  # This sub_word may be voted
  # into different categories. This Hash contains for
  # every voted category one key and behind that key,
  # we have the number of votes for this sub_word belonging
  # into this category, e.g. the sub_word is "Berlin" and
  # the categories are "cities", "trees" and "animals". Then
  # the votes Hash could look like this:
  # {
  #   "cities" => 4,
  #   "trees" => 2,
  #   "animals" => 0
  # }

  validates_presence_of :name
  validates_presence_of :category

  validates_format_of :name, :without => / - /
  validates_format_of :name, :without => /;/

  def vote_up(category)
    if self.votes[category].nil?
      self.votes[category] = 1
    else
      self.votes[category] += 1
    end
    self.save!
  end

  def get_votes_for(category)
    if self.votes[category].nil?
      return(0)
    else
      return(self.votes[category])
    end
  end

end
