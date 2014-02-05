class Vote
	include Mongoid::Document
	include Mongoid::Timestamps

	field :time_left, type: Integer
	field :session_uri, type: String
	field :voter_id, type: String
	field :duration, type: Integer

end