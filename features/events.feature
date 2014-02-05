Feature: Create und manage events
	As a lecturer 
	I want to be able to define events
	In order to have a container to ask surveys in

	Background:
	 # Given I am logged in
	 Given I am logged in as a user

	Scenario: List events
    Given there exists an event with the name "test event"
    When I go to the events page
    Then I should see "test event"
  
  Scenario: Only show own events
    Given there exists an event with the name "first event"
    And I am logged in as the user with email "test2@example.com"
    And there exists an event with the name "my own event"
    When I go to the events page
    Then I should see "my own event"
    But I should not see "first event"
  
  Scenario: Create a custom event
    When I go to the new event page
    And I fill in "event_name" with "my event"
    And I fill in "event_description" with "this is a description"
    And I press "OK"
    And I go to the events page
    Then I should see "my event"
    And I should see "this is a description"

  Scenario: Add survey to event
    Given there exists an event with the name "test event"
    When I go to the event's page
    And I press "new-event-survey_submit"
    Then I should see "Survey successfully created"