class QuestionComment
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :question
  belongs_to :survey, optional: true

  field :text, type: String
  validates :text, presence: true

end