# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)
puts 'EMPTY THE MONGODB DATABASE'
Mongoid.master.collections.reject { |c| c.name =~ /^system/}.each(&:drop)
puts 'SETTING UP DEFAULT USER LOGIN'
user = User.create! :name => 'admin', :email => 'user@test.com', :password => 'please',
                    :password_confirmation => 'please', :admin => true,
                    :first_name => 'Max', :last_name => 'Mustermann',
                    :organization => 'Universität Paderborn',
                    :faculty => 'Fakultät für Wirtschaftswissenschaften',
                    :chair => 'PINGO'
puts 'user@test.com created (Password: please): ' << user.email
