require 'spec_helper'

describe QuestionsController do

  def create_hackable_question 
    @question = create_multiple_choice_question
    @user = FactoryGirl.create(:user)
    @question.user = @user
    @question.save!
  end

  describe "update" do
    it "prevents updating foreign questions" do
      create_hackable_question
      login_hacker

      post :update, id: @question.id, question: { name: "foo" }
      expect(response.status).to eq(403)
      expect(@question.reload.name).not_to eq("foo")
    end

    it "allows updating own questions" do
      create_hackable_question
      sign_in @user

      post :update, id: @question.id, question: { name: "foo" }
      expect(response.status).to eq(302)
      expect(@question.reload.name).to eq("foo")
    end

    it "allows updating shared questions" do
      create_hackable_question
      login_hacker
      @question.collaborators << @hacker
      @question.save!

      post :update, id: @question.id, question: { name: "foo" }
      expect(response.status).to eq(302)
      expect(@question.reload.name).to eq("foo")
    end

    it "allows sharing questions" do
      create_hackable_question
      sign_in @user
      hacker = FactoryGirl.create(:hacker)

      post :update, id: @question.id, question: { collaborators_form: [hacker.id] }
      expect(response.status).to eq(302)
      expect(@question.reload.collaborator_ids).to include(hacker.id)
    end
  end

  describe "transform" do
    it "allows transforming questions" do
      create_hackable_question
      sign_in @user

      post :transform, id: @question.id
      expect(response.status).to eq(302)
    end

    it "prevents transforming foreign questions" do
      create_hackable_question
      login_hacker

      post :transform, id: @question.id
      expect(response.status).to eq(403)
    end

    it "allows transforming shared questions" do
      create_hackable_question
      login_hacker
      @question.collaborators << @hacker
      @question.save!

      post :transform, id: @question.id
      expect(response.status).to eq(302)
    end
  end

  describe "show" do 
    it "allows showing public questions" do 
      create_hackable_question
      @question.update_attributes(public: true)
      login_hacker

      get :show, id: @question.id
      expect(response.status).to eq(200)
    end

    it "allows showing shared questions" do
      create_hackable_question
      login_hacker
      @question.collaborators << @hacker
      @question.save!

      get :show, id: @question.id
      expect(response.status).to eq(200)
    end
  end

  describe "edit" do 
    it "prevents editing foreign questions" do 
      create_hackable_question
      login_hacker

      get :edit, id: @question.id
      expect(response.status).to eq(403)
    end

    it "allows admins to edit foreign questions" do 
      create_hackable_question
      login_hacker
      @hacker.update_attribute(:admin, true)

      get :edit, id: @question.id
      expect(response.status).to eq(200)
    end

    it "allows editing own questions" do 
      create_hackable_question
      sign_in @user

      get :edit, id: @question.id
      expect(response.status).to eq(200)
    end

    it "allows editing shared questions" do
      create_hackable_question
      login_hacker
      @question.collaborators << @hacker
      @question.save!

      get :edit, id: @question.id
      expect(response.status).to eq(200)
    end
  end
end
