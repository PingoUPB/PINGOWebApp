Feature: Voting
	As a student
	I want to vote on surveys
	In order to participate in the lecture

	Background:
	 Given I exist as a user
	 And there exists an event
  
  @javascript
	Scenario: Vote for single choice questions
	  Given a survey with some options exists
	  And the survey is running
	  And I am on the root page
	  And I fill in "id" with the event's number
	  And I press "Rock the vote"
	  When I select the first option
	  And I press "Vote!"
	  Then I should see "Thanks for voting"
	  
	@javascript
	Scenario: Voting twice for single choice questions is not allowed
	  Given a survey with some options exists
	  And the survey is running
	  And I am on the root page
	  And I fill in "id" with the event's number
	  And I press "Rock the vote"
	  When I select the first option
	  And I press "Vote!"
    And I select the first option
	  And I press "Vote!"
	  Then I should see "you cannot vote on this survey anymore"
	  But I should not see "Thanks for voting"
	  
	Scenario: Vote for text questions
	  Given a text survey exists
	  And the survey is running
	  And I am on the root page
	  And I fill in "id" with the event's number
	  And I press "Rock the vote"
	  When I fill in "option[]" with "My Answer"
	  And I press "Vote!"
	  Then I should see "Thanks for voting"
	  
	Scenario: Vote for numeric questions
	  Given a numeric survey exists
	  And the survey is running
	  And I am on the root page
	  And I fill in "id" with the event's number
	  And I press "Rock the vote"
	  When I fill in "option" with "42"
	  And I press "Vote!"
	  Then I should see "Thanks for voting"