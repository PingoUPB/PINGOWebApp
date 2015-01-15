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
    
  @javascript
  Scenario: Sharing works and a shared event can be viewe
    Given the user with email "test_share2@example.com" exists
    And I am logged in as the user with email "test_share1@example.com"
    And there exists an event with the name "unshared event"
    And there exists an event with the name "shared event"
    And I go to the event's page
    And I follow "editEventLink"
    And I fill in "mail_for_collaborators" with "test_share2@example.com"
    And I hit enter in "mail_for_collaborators"
    And I wait a second
    And I press "OK"
    And I am logged in as the user with email "test_share2@example.com"
    And I go to the event's page
    Then I should see "shared event"
    And I should not see "You do not have access"
    
  @javascript
  Scenario: Shared events show up in the events list
    Given the user with email "test_share3@example.com" exists
    And I am logged in as the user with email "test_share4@example.com"
    And there exists an event with the name "unshared list event"
    And there exists an event with the name "shared list event"
    And I go to the event's page
    And I follow "editEventLink"
    And I fill in "mail_for_collaborators" with "test_share3@example.com"
    And I hit enter in "mail_for_collaborators"
    And I wait a second
    And I press "OK"
    And I am logged in as the user with email "test_share3@example.com"
    When I go to the events page
    And I follow "sharedEventsLink"
    Then I should see "shared list event"
    And I should not see "unshared list event"

  Scenario: Add survey to event
    Given there exists an event with the name "test event"
    When I go to the event's page
    And I press "new-event-survey_submit"
    Then I should see "Survey successfully created"

  @javascript
  Scenario: Change survey language
    Given there exists an event with the name "test event"
    And I go to the event's edit page
    And I select "German" from "event_custom_locale_select"
    And I press "new_event_submit"
    Then I should see "Umfragen"
