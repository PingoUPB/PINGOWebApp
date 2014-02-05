class Metric
	include Mongoid::Document
	include Mongoid::Timestamps::Created

	field :name, type: String
	index :name
	
	field :meta, type: String

  # just call `Metric.track :my_event_name` some place
  def self.track(name, meta = nil)
    Metric.create(name: name.to_s, meta: meta)
  end

  # just call `Metric.track_error :my_event_name` some place
  def self.track_error(name, meta = {})
    meta = meta.merge({type: "error"}) if !meta.has_key?(:type) || !meta.has_key?("type")
    Metric.create(name: name.to_s, meta: meta)
  end

end