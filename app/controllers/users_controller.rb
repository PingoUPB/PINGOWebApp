class UsersController < ApplicationController
 before_action :authenticate_user_from_token!
 before_action :authenticate_user!

  def show
    @user = User.find(params[:id])
  end


end
