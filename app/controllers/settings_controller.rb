class SettingsController < Devise::RegistrationsController

  def update
    @user = current_user
    email_changed = @user.email != params[:user][:email]
    password_changed = !params[:user][:password].empty?
    successfully_updated = if email_changed or password_changed
      @user.update_with_password(user_params)
    else
      @user.update_without_password(user_params)
    end

    if successfully_updated
      # Sign in the user bypassing validation in case his password changed
      sign_in @user, bypass: true
      redirect_to root_path, notice: t("devise.registrations.updated")
    else
      render "edit"
    end
  end
  
  # http://stackoverflow.com/a/15017055/238931
  def create
    super
    if @user.newsletter
      @user.generate_newsletter_token
      @user.save
    end
    UserMailer.welcome(@user).deliver unless @user.invalid?
  end
  
  def reset_auth_token
    @user = current_user
    @user.reset_authentication_token!
    redirect_to root_path, notice: t("messages.token_reset_success")
  end
  
  def user_params
    params.require(:user).permit([:first_name, :last_name, :organization, :faculty, :user_comment, :newsletter, :wants_sound])
  end

end