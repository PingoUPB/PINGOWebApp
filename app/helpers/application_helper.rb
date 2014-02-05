module ApplicationHelper
  include ::BootstrapHelper

  def title(page_title)
    content_for(:title, page_title.to_s)
  end

  ANSWER_CHOICES = (2..9).to_a
  DURATION_CHOICES = [0, 30, 45, 60, 120, 180, 300]
  TEXT_CHOICES = [TextSurvey::ONE_ANSWER, TextSurvey::THREE_ANSWERS, TextSurvey::MULTI_ANSWERS]

  def answer_choices
    ANSWER_CHOICES
  end

  def text_choices(p_locale = I18n.locale)
    TEXT_CHOICES.map do |choice|
      [t(choice, locale: p_locale), choice]
    end
  end

  def duration_choices(future = false)
    Hash[DURATION_CHOICES.map do |duration|
      if duration == 0  
        [(future ? t("now") : t("w_out_countdown")), duration]    
      else
        min = Time.at(duration).strftime("%M").to_i
        sec = Time.at(duration).strftime("%S").to_i
        result = ""
        result += min.to_s+" "+t("min")+" " if min > 0
        result += sec.to_s+" "+t("sec") if sec > 0
        [(future ? "in " : "") + result , duration]
      end 
    end]
  end

  def quick_start_settings
    settings = current_user.quick_start_settings
    return settings if settings.count == 3
    return Hash["options", 4, "duration", 60, "multi", false]
  end

  
  # https://github.com/plataformatec/devise/wiki/How-To:-Display-a-custom-sign_in-form-anywhere-in-your-app
  def resource_name
    :user
  end
 
  def resource
    @resource ||= User.new
  end
 
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def upb_network?
    upb_net = ENV["ORG_SUBNET"]||"131.234.0.0/16"
    upb = IPAddr.new(upb_net)
    upb === request.remote_ip
  end
  
end
