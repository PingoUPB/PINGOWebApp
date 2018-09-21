class ApplicationController < ActionController::Base
  protect_from_forgery
  #before_filter :check_ip
  before_action :setup_test_helper
  before_action :configure_permitted_parameters, if: :devise_controller?

  # for lograge, add IP to logs
  def append_info_to_payload(payload)
    super
    payload[:ip] = request.remote_ip
  end

  private
  MOBILE_BROWSERS = ["android", "ipod", "ipad", "iphone", "opera mini", "blackberry", "palm","hiptop","avantgo","plucker", "xiino","blazer","elaine", "windows ce; ppc;", "windows ce; smartphone;","windows ce; iemobile", "up.browser","up.link","mmp","symbian","smartphone", "midp","wap","vodafone","o2","pocket","kindle", "mobile","pda","psp","treo"]

  protected

  def default_url_options(options={})
    if params[:tour] == "true" # keep tour mode turned on while surfing around
      { :tour => "true" }
    else
      {}
    end
  end

  def require_admin
    redirect_to root_path, alert: "Admins would have been able to view the requested page. But not you..." unless current_user.admin?
  end

  def detect_browser
    return "mobile_application" if is_mobile? && cookies[:mobile_view] != "0"
    return "application"
  end

  def is_mobile?
    agent = (request.headers["HTTP_USER_AGENT"]||"").downcase
    MOBILE_BROWSERS.each do |m|
      return true if agent.match(m)
    end
    return false
  end

  # Can check for a specific user agent
  # e.g., is_device?('iphone') or is_device?('mobileexplorer')
  def is_device?(type)
    request.user_agent.to_s.downcase.include?(type.to_s.downcase)
  end
  helper_method :is_device?

  def is_numeric?(i)
      i.to_i.to_s == i || i.to_f.to_s == i
  end

  def get_or_create_voter_id
    if user_signed_in?
      return current_user.voter_id
    else
      cookies.permanent[:voter_id] = @@uuid.generate  if cookies[:voter_id].blank?
      return cookies[:voter_id]
    end
  end

  # use as a filter
  def check_ip
    upb_net = ENV["ORG_SUBNET"]||"131.234.0.0/16"
    upb = IPAddr.new(upb_net)
    @upb_ip = (upb === request.remote_ip)
  end

  def start_countdown_worker(id)
    if Rails.env.production? || Rails.env.staging?
        Resque.enqueue(ResqueCountdownWorker, id, ENV["REDISTOGO_URL"])
    else
      #worker.run_local #(:timeout=>30) # note: this is blocking!
    end
  end

  def publish_push_notification(channel, message)
    unless ENV["USE_JUGGERNAUT"] == "false" # && ENV["USE_PUSH"] == "false"
      begin
        unless ENV["FAYE_ENABLED"] == "false"
          url = URI.parse(ENV["PUSH_URL"])
          request = Net::HTTP::Post.new(url.path)
          request.content_type = "application/json"
          request.body = {message: {channel: channel, data: message}}.to_json
          Net::HTTP.start(url.host, url.port, :read_timeout => 2) {|http| http.request(request)}
        end
        unless ENV["JUGGERNAUT_ENABLED"] == "false"
          Juggernaut.publish(channel.gsub("/", ""), message)
        end
      rescue => e
        puts "Error publishing the push message:"
        Metric.track_error :my_event_name, exception_message: e.message.to_s
      end
    else
      logger.info("would have sent a push notification to Juggernaut")
    end
  end

  def setup_test_helper
    if Rails.env.test?
      I18n.locale = :en
    end
  end

  def set_locale_for_event_or_survey
    if @event && !@event.custom_locale.blank?
      I18n.locale = @event.custom_locale
      Rails.logger.info "set locale to #{@event.custom_locale}"
    elsif @survey && !@survey.event.custom_locale.blank?
      I18n.locale = @survey.event.custom_locale
      Rails.logger.info "set locale to #{@survey.event.custom_locale}"
    end
  end
  
  
  protected
  
  # https://gist.github.com/josevalim/fb706b1e933ef01e4fb6
    # For this example, we are simply using token authentication
    # via parameters. However, anyone could use Rails's token
    # authentication features to get the token from a header.
    def authenticate_user_from_token!
      user_token = params[:auth_token].presence
      user       = user_token && User.where(authentication_token: user_token.to_s).first

      if user
        # Notice we are passing store false, so the user is not
        # actually stored in the session and a token is needed
        # for every request. If you want the token to work as a
        # sign in token, you can simply remove store: false.
        sign_in user, store: false
      end
    end
    
    def configure_permitted_parameters
      allowed_user_keys = [:first_name, :last_name, :organization, :faculty, :user_comment, :newsletter]
      devise_parameter_sanitizer.permit(:sign_up, keys: allowed_user_keys)
      devise_parameter_sanitizer.permit(:account_update, keys: allowed_user_keys +  [:wants_sound])
    end

end
