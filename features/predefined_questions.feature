Feature: Pre-define questions
	As a lecturer 
	I want to be able to pre-define questions with answers
	In order to ask them during lectures

	Background:
	 # Given I am logged in
	 Given I am logged in as a user

	Scenario: List questions
    Given there exists a single choice question with the name "test question" for "example@example.com"
    When I go to the questions page
    Then I should see "test question"

  @javascript
  Scenario: Create single Choice questions
    Given I go to the questions page
    And I follow "Create question"
    And I follow "Single Choice"
    When I fill in "single_question_name" with "my test question"
    And I fill in "question_question_options_attributes_0_name" with "first option"
    And I press "Create Question"
    Then I should see "Question successfully created"

  @javascript
  Scenario: Create multiple choice questions
    Given I go to the questions page
    And I follow "Create question"
    And I follow "Multiple Choice"
    When I fill in "multi_question_name" with "my 2nd test question"
    And I fill in "question_question_options_attributes_0_name" with "first option" within "#multi-tab"
    And I press "Create Question" within "#multi-tab"
    Then I should see "Question successfully created"

 @javascript
  Scenario: Add public questions to own set of questions
    Given there exists a public question with the name "public_question"
    And I go to the questions page
    And I follow "Public"
    And I follow "public_question"
    When I press "Add to own questions"
    Then I should see "public_question"

  Scenario: Edit questions
    Given there exists a single choice question with the name "my test question" for "example@example.com"
    And I go to the questions page
    And I follow "my test question"
    And I follow "edit"
    When I fill in "Name" with "my edited test question"
    And I press "Update Question"
    Then I should see "Question successfully updated"
    And I go to the questions page
    And I should see "my edited test question"

  @wip
  @javascript
  Scenario: Delete questions
    Given there exists a single choice question with the name "my test question" for "example@example.com"
    And I go to the questions page
    And I follow "my test question"
    And I follow "delete" and confirm the popup
    And I go to the questions page
    Then I should not see "my test question"
  
  @javascript
  Scenario: Tag questions
    Given there exists a single choice question with the name "my test question" for "example@example.com"
    And I tag "my test question" with "winfo"
    And there exists a single choice question with the name "my second question" for "example@example.com"
    And I tag "my second question" with "wiwi"
    When I go to the questions page
    Then I should see "winfo"
    And I should see "wiwi"
    And I follow "winfo"
    And I should see "my test question"
    But I should not see "my second question"

  Scenario: View only questions owned by me
     Given there exists a single choice question with the name "my own question" for "example@example.com"
     And the user with email "example2@example.com" exists
     And there exists a single choice question with the name "foreign question" for "example2@example.com"
     When I go to the questions page
     Then I should see "my own question"
     But I should not see "foreign test question"

  Scenario: Create public single Choice questions
     Given I go to the questions page
     And I follow "Create question"
     And I follow "Single Choice"
     When I fill in "single_question_name" with "my public test question"
     And I check "Public"
     And I fill in "question_question_options_attributes_0_name" with "first option"
     And I press "Create Question"
     And I follow "Public"
     Then I should see "my public test question"

  @javascript
  Scenario: Add questions to session from session view (ad hoc)
    Given there exists a single choice question with the name "my test question" for "example@example.com"
    And there exists an event with the name "some event"
    When I go to the events page
    And I follow "show"
    And I follow "Start question from list"
    And I add the first question in the list
    And I go to the event's page
    Then I should see "my test question"

    