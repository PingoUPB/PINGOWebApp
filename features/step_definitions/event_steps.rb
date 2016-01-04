Given /^there exists an event$/ do 
  @event = FactoryGirl.create(:event, user: @user)
end

Given /^there exists an event with the name "(.*?)"$/ do |name| 
  @event = FactoryGirl.create(:event, name: name, user: @user)
end

When /^I add the first question in the list$/ do
  page.find(:css, ".add_question_link").click
end