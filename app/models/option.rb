class Option
  include Mongoid::Document
  
   embedded_in :survey
   field :name, type: String
   field :description, type: String
   field :votes, type: Integer, default: 0
   field :correct, type: Boolean, default: nil
   
   validates_presence_of :name
   
   def vote_up
     self.inc(votes: 1)
   end
   
   def vote_down
     self.inc(votes: -1)
   end
end
