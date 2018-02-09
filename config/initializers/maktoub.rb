#Maktoub.from = "" # the email the newsletter is sent from
# Maktoub.twitter_url = "https://twitter.com/" # your twitter page
# Maktoub.facebook_url = "https://www.facebook.com/" # your facebook oage
#Maktoub.subscription_preferences_url = "https://" #subscribers management url
#Maktoub.logo = "logo.png" # path to your logo asset
#Maktoub.home_domain = "" # your domain
#Maktoub.app_name = "PINGO" # your app name
# Maktoub.unsubscribe_method = "unsubscribe" # method to call from unsubscribe link (doesn't include link by default)

# pass a block to subscribers_extractor that returns an object that  reponds to :name and :email
# (fields can be configured as shown below)

# require "ostruct"
#Maktoub.subscribers_extractor do
#  User.where(newsletter: true).to_a
#end

# uncomment lines below to change subscriber fields that contain email and
# Maktoub.email_field = :address
# Maktoub.name_field = :nickname