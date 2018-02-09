Given /^there exists an event$/ do 
  @event = FactoryBot.create(:event, user: @user)
end

Given /^there exists an event with the name "(.*?)"$/ do |name| 
  @event = FactoryBot.create(:event, name: name, user: @user)
end

When /^I add the first question in the list$/ do
  page.find(:css, ".add_question_link").click
end
