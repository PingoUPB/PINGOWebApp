class QuestionOption
  include Mongoid::Document
  
   embedded_in :question
   field :name, type: String
   field :correct, type: Boolean, defaut: false
   # smthing like couterpart options...
   
   validates_presence_of :name

   def to_option
   	option = Option.new
   	option.name = self.name
   	option.correct = self.correct
   	option
   end
end
