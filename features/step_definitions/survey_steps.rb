Given /^a survey exists$/ do 
  if @event
    @survey = FactoryBot.create(:survey, event: @event)
  else
    @survey = FactoryBot.create(:survey)
  end
end

Given /^a survey with some options exists$/ do 
  if @event
    @survey = FactoryBot.create(:survey_with_options, event: @event)
  else
    @survey = FactoryBot.create(:survey_with_options)
  end
end

Given /^a text survey exists$/ do
  if @event
    @survey = FactoryBot.create(:text_survey, event: @event)
  else
    @survey = FactoryBot.create(:text_survey)
  end
end

Given /^a numeric survey exists$/ do
  if @event
    @survey = FactoryBot.create(:numeric_survey, event: @event)
  else
    @survey = FactoryBot.create(:numeric_survey)
  end
end

Given /^the survey is running$/ do 
  if @survey
    @survey.service.start!
  else
    raise "No current @survey obj found"
  end
end
