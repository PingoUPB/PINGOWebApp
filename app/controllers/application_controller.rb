class ApplicationController < ActionController::Base
  protect_from_forgery
  #before_filter :check_ip
  before_filter :setup_test_helper
  
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
      if ENV["PLATFORM"] == "heroku"
        worker = CountdownWorker.new
        worker.url = ENV["REDISTOGO_URL"]
        worker.sid = id
        worker.queue(timeout: 120) #because atm we're on a free 5hrs/month plan ;)
      else
        Resque.enqueue(ResqueCountdownWorker, id, ENV["REDISTOGO_URL"])
      end
    else
      #worker.run_local #(:timeout=>30) # note: this is blocking!
    end
  end
  
  def publish_push_notification(*args)
    unless ENV["USE_JUGGERNAUT"] == "false"
      begin
        Juggernaut.publish(*args)
      rescue => e
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
    
end
