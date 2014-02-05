class AnnouncementMailer < ActionMailer::Base
  default from: "PINGO <pingo-support@uni-paderborn.de>"
  def announcement_email(recipient)
    mail(to: recipient,
         reply_to: "pingo-support@uni-paderborn.de",
         subject: "Wichtige Ankuendigung bzgl. PINGO / Important notice regarding PINGO"
        )
  end
end
