class Category
  include Mongoid::Document

  embedded_in :question
  embedded_in :survey
  field :name, type: String
  field :description, type: String
  field :sub_words, type: String

  validates_presence_of :name
  validates_presence_of :sub_words # semicolon-seperated words, e.g.
  # "word1;word2;word3"

  validates_format_of :name, :without => / - /

end
