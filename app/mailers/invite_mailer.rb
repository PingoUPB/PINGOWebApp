class InviteMailer < ActionMailer::Base
  def invite_email(recipient, inviter)
    @user = inviter
    mail(from: "#{inviter.name} via PINGO <pingo-support@uni-paderborn.de>",
         to: recipient,
         reply_to: inviter.email
        )
  end
end
