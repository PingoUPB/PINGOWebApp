class RelativeOptionOrderObject
  include Mongoid::Document

  embedded_in :question
  embedded_in :survey

  # Every order_option is a key in this hash.
  # Its value is another hash, in which all
  # the other order_options are a key, and
  # behind each key you find the number of
  # votes, indicating that this order_option
  # belongs after the super order_option. E.g.
  #
  # contentHash:
  # {
  #   "A" => {
  #     "B" => 2, //i.e. 2 people voted, that A belongs before B
  #     "C" => 4  //i.e. 4 people voted, that A belongs before B
  #   },
  #   "B" => {
  #     "A" => 2,
  #     "C" => 3
  #   },
  #   "C" => {
  #     "A" => 0,
  #     "B" => 1
  #   }
  # }
  field :contentHash, type: Hash

  def vote_up(beforeName, afterName)
    if self.contentHash[beforeName].nil?
      self.contentHash[beforeName] = Hash[afterName, 1]
    elsif self.contentHash[beforeName][afterName].nil?
      self.contentHash[beforeName][afterName] = 1
    else
      self.contentHash[beforeName][afterName] += 1
    end
  end

  def get_votes_for(beforeName, afterName)
    if self.contentHash[beforeName][afterName].nil?
      return(0)
    else
      return(self.contentHash[beforeName][afterName])
    end
  end

end