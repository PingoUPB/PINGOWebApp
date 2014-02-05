if Rails.env.production?
  Mongoid.add_language("de")
  Mongoid.add_language("es")
end