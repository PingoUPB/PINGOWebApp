module PINGOSpecHelpers
  def create_multiple_choice_question 
    question = MultipleChoiceQuestion.new
    question.name = "My Question"
    question
  end

  def login_user
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user = FactoryBot.create(:user)
    sign_in user
    @user = user
  end

  def login_hacker
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user = FactoryBot.create(:hacker)
    sign_in user
    @hacker = user
  end
end
