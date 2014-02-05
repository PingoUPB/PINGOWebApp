Given /^I fill in "(.*?)" with the event's number$/ do |field|
  fill_in(field, :with => @event.token)
end

When /^I select the first option$/ do
  page.find(:css, "input[name='option']").click
end