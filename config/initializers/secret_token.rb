# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
Eclickr::Application.config.secret_token = ENV["PINGO_RAILS_SECRET_TOKEN"] || '5548dc196d703e5c0e3c09f46da80b10b3bc44f966195bc65ff637715f7920171eedbf93876b2f72ad7d58da2dd994e59551c6004cd8d50a8b062ab90ccc29bc'
