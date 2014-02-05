Given /^there exists a single choice question with the name "(.*?)" for "(.*?)"$/ do |name, user|
  Question.create!(name: name, type: "single", user: get_user_by_mail(user))
end

Given /^there exists a multi choice question with the name "(.*?)" for "(.*?)"$/ do |name, user|
  Question.create!(name: name, type: "multi", user: get_user_by_mail(user))
end

Given /^there exists a public question with the name "(.*?)"$/ do |name|
  Question.create!(name: name, type:"multi", public: true)
end

When /^I create the single choice question "(.*?)" with the answers "(.*?)"$/ do |name, answers|
  q = Question.create!(name: name, type: "single", user: @user)
  populate_question_with_answers!(q, answers)
end

When /^I create the multiple choice question "(.*?)" with the answers "(.*?)"$/ do |name, answers|
  q = Question.create!(name: name, type: "multiple", user: @user)
  populate_question_with_answers!(q, answers)
end

Given /^I tag "(.*?)" with "(.*?)"$/ do |name, tag|
  q = Question.where(name: name).first
  q.tags = tag
  q.save!
end

def get_user_by_mail(user)    # Model.find_by_ATTR will be deprecated in Rails 4
  user_obj = User.where(email: user).first
  raise "E-Mail '#{user}' not found (while creating a user's question)" if user_obj.nil?
  user_obj
end

def populate_question_with_answers!(q, answers, delimiter = ", ")
  answers.split(delimiter).each do |answer|
    q.question_options.create!(name: answer)
  end
end