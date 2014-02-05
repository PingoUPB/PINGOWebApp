Feature: Show Users
  As a admin to the website
  I want to see registered users listed on the admin page
  so I can know if the site has users

  	@wip
    Scenario: Viewing users
      Given I am a user named "admin" with an email "admin@test.com" and password "superadmin"
      And I sign in as "admin@test.com/superadmin"
      When I go to the admin users page
      Then I should see "foo"
