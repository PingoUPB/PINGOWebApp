class HomeController < ApplicationController
  layout :detect_browser
  #caches_action :index, layout: false, expires_in: 1.hour
  
  if defined?(NewRelic)
    newrelic_ignore_apdex only: [:stats]
  end

  def index
    if user_signed_in?
       @posts = Rails.cache.fetch("pingo.blogs", :expires_in => 4.hours) do
         get_blog_posts("http://blogs.uni-paderborn.de/pingo/feed/")
      end
    end
  end
  
  def newsletter
    if !params[:token].blank?
      @newsletter_user = User.where(newsletter_optin_token: params[:token]).first
      if @newsletter_user
        @newsletter_user.update_attribute(:newsletter_confirmed_at, Time.now)
      else
        render plain: "Invalid Link, ungueltiger Link"
      end
    else
      render plain: "Invalid Link, ungueltiger Link"
    end
  end

# :nocov:
  def stats
    @users = User.count
    @sessions = Event.count
    @surveys = Survey.count
    @repeated_surveys = @surveys - Survey.where(original_survey_id: nil).count
    @questions = Question.count
    @public_questions = Question.where(public: true).count
    @votes = Rails.cache.fetch("pingo.stats.votes_sum", :expires_in => 30.minutes) do
      Survey.only(:voters).map { |s| s.voters ? s.voters.count : 0 }.sum
   end
    @invitations = Metric.where(name: "invitation").count
    @newsletter_users = User.where(newsletter: true).count

    respond_to do |format|
      format.html
      format.json do
        render json: {
          users: (current_user.try(:admin) ? @users : -1),
          sessions: @sessions,
          surveys: @surveys,
          repeated_surveys: @repeated_surveys,
          questions: @questions,
          public_questions: @public_questions,
          votes: @votes
        }
      end
    end
  end
# :nocov:

  def switch_view
    if params[:mobile] == "0"
      cookies.permanent[:mobile_view] = "0"
    else
      cookies.permanent[:mobile_view] = "1"
    end
    #edirect_to :back, notice: 'View changed.'
    #rescue ActionController::RedirectBackError
    redirect_to root_path
  end

  def blitz #for blitz.io
    render :plain => "42"
  end

  private
  def get_blog_posts(url)
    begin
      feed = nil
      open(url) do |rss|
        feed = RSS::Parser.parse(rss)
      end

      unless feed.nil?
        feed.items
      else
        []
      end
    rescue
      []
    end
  end

end
