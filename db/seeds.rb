# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)
require 'securerandom'


puts 'SETTING UP DEFAULT USER LOGIN'
random_password = SecureRandom.urlsafe_base64(6)
user = User.create! :email => 'user@example.com', :password => random_password,
                    :password_confirmation => random_password, :admin => true,
                    :first_name => 'Max', :last_name => 'Mustermann',
                    :organization => 'Meine Uni',
                    :faculty => 'Meine Fakultaet',
                    :chair => 'PINGO'
puts 'user@example.com created with password: ' << random_password