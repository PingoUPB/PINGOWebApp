if Rails.env.production?
  ActionMailer::Base.smtp_settings = {
  }
elsif Rails.env.staging?
  ActionMailer::Base.smtp_settings = {
  }
end