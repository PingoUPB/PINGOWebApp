class InvitationsController < ApplicationController
  before_action :authenticate_user!
  
  def new
    if I18n.locale == :es
      redirect_to root_path, notice: "Inviting users to PINGO is currently not available in Spanish, sorry. Just send your friends a link!"
    end
  end

  def deliver
    if params[:recipient][:mail].match(/^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})$/)
      InviteMailer.invite_email(params[:recipient][:mail], current_user).deliver
      Metric.track("invitation")
      redirect_to invitation_path, notice:  t('messages.invite_success')
    else
      redirect_to invitation_path, alert: t('messages.invite_fail')
    end
  end
end
