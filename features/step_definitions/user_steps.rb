### WARDEN DIRECT STEP ###
Given /^I am logged in as a user$/ do
  create_user
  login_as(@user, :scope => :user)
end

Given /^I am logged in as the user with email "(.*?)"$/ do |email|
  found_users = User.where(email: email)
  unless found_users.any?
    create_visitor
    @visitor[:email] = email
    @user = FactoryGirl.create(:user, email: @visitor[:email])
  else
    @user = found_users.first
  end
  login_as(@user, :scope => :user)
end

### GIVEN ###
Given /^I am not logged in$/ do
  visit '/users/sign_out'
end

Given /^I am logged in$/ do
  create_user
  sign_in
end

Given /^I am logged in as another user$/ do
  create_user2
  sign_in
end

Given /^I exist as a user$/ do
  create_user
end

Given /^the user with email "(.*?)" exists$/ do |email|
  create_visitor
  @visitor[:email] = email
  @user = FactoryGirl.create(:user, email: @visitor[:email])
end

Given /^the user named "(.*?)" with email "(.*?)" exists$/ do |name, email|
  create_visitor
  @visitor[:email] = email
  @visitor[:first_name] = name.rpartition(" ").first
  @visitor[:last_name] = name.rpartition(" ").last
  @user = FactoryGirl.create(:user, email: @visitor[:email], first_name: @visitor[:first_name], last_name: @visitor[:last_name])
end

Given /^I do not exist as a user$/ do
  create_visitor
  delete_user
end

Given /^I exist as an unconfirmed user$/ do
  create_unconfirmed_user
end

### WHEN ###
When /^I sign in with valid credentials$/ do
  create_visitor
  sign_in
end

When /^I sign out$/ do
  visit '/users/sign_out'
end

When /^I sign up with valid user data$/ do
  create_visitor
  sign_up
end

When /^I sign up with an invalid email$/ do
  create_visitor
  @visitor = @visitor.merge(:email => "notanemail")
  sign_up
end

When /^I sign up without a password confirmation$/ do
  create_visitor
  @visitor = @visitor.merge(:password_confirmation => "")
  sign_up
end

When /^I sign up without a password$/ do
  create_visitor
  @visitor = @visitor.merge(:password => "")
  sign_up
end

When /^I sign up with a mismatched password confirmation$/ do
  create_visitor
  @visitor = @visitor.merge(:password_confirmation => "please123")
  sign_up
end

When /^I return to the site$/ do
  visit '/'
end

When /^I sign in with a wrong email$/ do
  @visitor = @visitor.merge(:email => "wrong@example.com")
  sign_in
end

When /^I sign in with a wrong password$/ do
  @visitor = @visitor.merge(:password => "wrongpass")
  sign_in
end

When /^I edit my account details$/ do
  click_link "Settings"
  fill_in "First name", :with => "newname"
  fill_in "Current password", :with => @visitor[:password]
  click_button "Update"
end

When /^I look at the list of users$/ do
  visit '/admin/users'
end

### THEN ###
Then /^I should be signed in$/ do
  page.should have_content "Logout"
  #page.should_not have_content "Sign up"
  page.should_not have_content "Login"
end

Then /^I should be signed out$/ do
 # page.should have_content "Sign up"
  page.should have_content "Login"
  page.should_not have_content "Logout"
end

Then /^I see an unconfirmed account message$/ do
  page.should have_content "You have to confirm your account before continuing."
end

Then /^I see a successful sign in message$/ do
  page.should have_content "Signed in successfully"
end

Then /^I should see a successful sign up message$/ do
  page.should have_content "Signed up successfully"
end

Then /^I should see an invalid email message$/ do
  page.should have_content "Email is invalid"
end

Then /^I should see a missing password message$/ do
  page.should have_content "Password can't be blank"
end

Then /^I should see a missing password confirmation message$/ do
  page.should have_content "Password doesn't match confirmation"
end

Then /^I should see a mismatched password message$/ do
  page.should have_content "Password doesn't match confirmation"
end

Then /^I should see a signed out message$/ do
  page.should have_content "Signed out successfully."
end

Then /^I see an invalid login message$/ do
  page.should have_content "Invalid email or password"
end

Then /^I should see an account edited message$/ do
  page.should have_content "You updated your account successfully."
end

Then /^I should see my name$/ do
  create_user
  page.should have_content @user[:first_name]
end

### UTILITY METHODS ###

def create_visitor
  @visitor = { :first_name => "Testy",
           :last_name => "McUserton",
            :email => "example@example.com",
            :organization => "test orga",
            :faculty => "test fac",
            :chair => "test chair",
            :password => "please",
            :admin => false,
            :password_confirmation => "please" }
end

def create_admin
  @visitor = { :first_name => "Super",
           :last_name => "User",
            :email => "admin@example.com",
            :organization => "test orga",
            :faculty => "test fac",
            :chair => "test chair",
            :password => "please",
            :admin => true,
            :password_confirmation => "please" }
end

def create_visitor2
  @visitor = { :first_name => "Testor",
           :last_name => "MacUsertoon",
            :email => "example2@example.com",
            :organization => "test orga",
            :faculty => "test fac",
            :chair => "test chair",
            :password => "please",
            :admin => false,
            :password_confirmation => "please" }
end

def find_user
  @user ||= User.where(:email => @visitor[:email]).first
end

def create_unconfirmed_user
  create_visitor
  delete_user
  sign_up
  visit '/users/sign_out'
end

def create_user
  create_visitor
  delete_user
  @user = FactoryGirl.create(:user, email: @visitor[:email])
end

def create_user2
  create_visitor2
  delete_user
  @user = FactoryGirl.create(:user, email: @visitor[:email])
end

def delete_user
  @user ||= User.where(:email => @visitor[:email]).first
  @user.destroy unless @user.nil?
end

def sign_up
  delete_user
  visit '/users/sign_up'
  fill_in "First name", :with => @visitor[:first_name]
  fill_in "Last name", :with => @visitor[:last_name]
  fill_in "University / organization", :with => @visitor[:organization]
  fill_in "Faculty", :with => @visitor[:faculty]
  fill_in "E-Mail", :with => @visitor[:email]
  fill_in "Password", :with => @visitor[:password]
  fill_in "Password confirmation", :with => @visitor[:password_confirmation]
  click_button "Sign up"
  find_user
end

def sign_in
  visit '/users/sign_in'
  fill_in "user_email", :with => @visitor[:email]
  fill_in "user_password", :with => @visitor[:password]
  click_button "Login"
end
