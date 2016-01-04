require 'spec_helper'

describe ApiController do


  def create_test_session
    @user = FactoryGirl.create(:user)
    @user.ensure_authentication_token!
  end

  describe "save_ppt_settings" do

    it "saves the given data to the ppt_settings hash" do
      create_test_session

      posted_hash = {"key"=>"value"}
      posted_filename = "test"
      
      post :save_ppt_settings, auth_token: @user.authentication_token, file: posted_filename, json_hash:  posted_hash, format: :json
      assert_equal response.status, 200
      assert_equal JSON.parse(response.body)["ppt_settings"][posted_filename], posted_hash
    end

  end


end