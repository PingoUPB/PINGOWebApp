class UserMailer < ActionMailer::Base
  default from: "PINGO <pingo-support@uni-paderborn.de>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.welcome.subject
  #
  def welcome(user)
    @name = user.name

    mail to: user.email
  end
end
