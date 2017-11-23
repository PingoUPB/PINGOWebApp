class EventsController < ApplicationController
  before_filter :authenticate_user!, :except => [:participate, :find]
  layout :detect_browser
  
  swagger_controller :events, "View, create and modify Events (aka 'PINGO Sessions')"

  # GET /events
  # GET /events.json
  def index
    if(params[:all] && current_user.admin?)
      @events = Event.all.desc(:created_at)
      @events = @events.limit(200) unless params[:all] == 'all'
    elsif params[:shared]
      @events = current_user.shared_events.desc(:created_at)
      redirect_to events_url, alert: "No shared sessions found." and return unless @events.any? # should not occur
    else
      @events = current_user.events.desc(:created_at)
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end
  
  swagger_api :index do |api|
        summary "Return a list of the user's events (aka Sessions)."
        api.param :form, :shared, :boolean, :optional, "Set this parameter to any value to display events that have been shared with the user. Omit to display user events."
        ApiController::add_auth_token_parameter(api, true)
        response :unauthorized
        response :not_found
        response :forbidden
  end

  def latest_survey
    @event = Event.find_by_token(params[:id])
    render json: @event.latest_survey
  end
  
  swagger_api :latest_survey do |api|
        summary "Get info about the latest/newest survey for the queried event."
        api.param :path, "id", :string, :required
        ApiController::add_auth_token_parameter(api, true)
        response :unauthorized
        response :not_found
        response :forbidden
  end

  # POST /find
  def find
    if params[:id] && params[:id].match(/\A\d{3,}\z/) # at least 3 digits
      redirect_to "/"+params[:id]
    else
      redirect_to root_path, alert: t("messages.survey_not_found")
    end
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @event = Event.find_by_id_or_token(params[:id])
    check_access
    return if performed?

    @surveys = @event.surveys.display_fields.desc(:created_at)

    respond_to do |format|
      format.html { set_locale_for_event_or_survey } # show.html.erb
      format.json { render json: @event, methods: :latest_survey }
      format.csv { export }
    end
  end
  
  swagger_api :show do |api|
        summary "Get info about the event and the latest/newest survey for the queried event."
        api.param :path, "id", :string, :required
        ApiController::add_auth_token_parameter(api, true)
        response :unauthorized
        response :not_found
        response :forbidden
  end

  # GET /events/new
  # GET /events/new.json
  def new
    @event = Event.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find_by_token(params[:id])

    check_access
    return if performed?

  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(event_params)
    @event.user = current_user

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: t("messages.session_successfully_created") }
        format.json { render json: @event, status: :created, location: @event }
      else
        format.html { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end
  
  swagger_api :create do |api|
        summary "Create a new event for the currently authenticated user."
        api.param :form, "event", :Event, :required, "Event info"
        ApiController::add_auth_token_parameter(api)
        response :created
        response :unprocessable_entity
        response :unauthorized
        response :forbidden
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event = Event.find_by_token(params[:id])

    check_access
    return if performed?

    respond_to do |format|
      if @event.update_attributes(event_params)
        current_user.contacts.concat (@event.collaborators - current_user.contacts)
        current_user.save

        format.html { redirect_to @event, notice: t("messages.session_successfully_updated") }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end
  
  swagger_api :update do |api|
        summary "Change details of an event for the currently authenticated user."
        api.param :path, "id", :string, :required
        api.param :form, "event", :Event, :required, "Event info"
        ApiController::add_auth_token_parameter(api)
        response :not_found
        response :unprocessable_entity
        response :unauthorized
        response :forbidden
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event = Event.find_by_token(params[:id])

    check_access
    return if performed?

    @event.destroy

    respond_to do |format|
      format.html { redirect_to events_url }
      format.json { head :ok }
    end
  end
  
  swagger_api :destroy do |api|
        summary "Delete an event. This cannot be undone, use with care as all associated survey data will be purged, as well."
        api.param :path, "id", :string, :required
        ApiController::add_auth_token_parameter(api)
        response :not_found
        response :unauthorized
        response :forbidden
  end

  # GET /events/1/connected
  def connected_users
    @event = Event.find_by_token(params[:id])
    render text: (@event.try(:current_viewers) || "-")
  end

  # POST /quick_start
  def quick_start
    @event = Event.new
    @event.name = "Quick Session"
    @event.user = current_user
    @survey = @event.surveys.build
    # @survey.name = t("quick_survey")
    @survey.quick = true

    if Question.question_types.include?(params[:q_type])
      @survey.type = params[:q_type]
    else
      @survey.type = "single"
      params[:q_type] = "single"
    end

    @survey = @survey.service

    if @survey.has_options?

      options = (is_numeric?(params[:options]) ? params[:options].to_i : 4)
      options = 26 if options > 26

      alphabet = %W(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)

      (1..options).each do |option|
        @survey.options.new(name: alphabet[option-1])
      end

    elsif params[:options] && @survey.has_settings?
      @survey.add_setting :answers, params[:options]
    end

    duration = (is_numeric?(params[:duration]) ? params[:duration].to_i : 0)

    if params[:remember_settings] == "1"
      current_user.quick_start_settings[:q_type] = params[:q_type]
      current_user.quick_start_settings[:options] = options
      current_user.quick_start_settings[:duration] = duration
      current_user.save!
    end

    respond_to do |format|
      if @event.save
        @survey.start!(duration)
        start_countdown_worker(@survey.id) if duration > 0
        format.html { redirect_to @event, notice: t("messages.session_survey_successfully_created") }
        format.json { render json: @survey, status: :created, location: @survey }
      else
        format.html { render action: "new" }
        format.json { render json: @survey.errors, status: :unprocessable_entity }
      end
    end
  end
  
  swagger_api :quick_start do |api|
        summary "Creates a new event with a running survey of the specified type."
        api.param_list :form, "q_type", :string, :optional, "Question type", Question.question_types
        api.param :form, "options", :integer, :optional, "Number of options for single/multiple choice surveys. Options will be alphabetically orderd. Maximum is 26."
        api.param :form, "duration", :integer, :required, "Duration of the running survey in seconds. Supply 0 for open end surveys."
        ApiController::add_auth_token_parameter(api)
        response :unprocessable_entity
        response :unauthorized
        response :forbidden
  end

  # POST /events/:id/add_question
  def add_question
    @event = Event.find_by_id_or_token(params[:id])

    check_access
    return if performed?

    question = Question.find(params[:question])
    @survey = question.to_survey
    @survey.event = @event

    unless params[:duration].nil?
      duration = (is_numeric?(params[:duration]) ? params[:duration].to_i : 0)
      @event.update_attribute(:default_question_duration, duration) if params[:remember_settings] == "1"
    else
      if @event.default_question_duration
        duration = @event.default_question_duration
      else
        duration = 0
      end
    end

    respond_to do |format|
      if @survey.save
        @survey.start!(duration)
        publish_push_notification("/sess/"+@survey.event.token.to_s, {:type => "status_change", :payload => "started", "timestamp" => Time.new})
        start_countdown_worker(@survey.id) if duration > 0
        format.html { redirect_to event_path(@survey.event), notice: t("messages.survey_successfully_created") }
        format.js
        format.json { head :ok }
      else
        format.html { render action: "new" }
        format.json { render json: @survey.errors, status: :unprocessable_entity }
      end
    end
  end
  
  swagger_api :add_question do |api|
        summary "Adds the supplied question to the event identified by :id"
        api.param :path, "id", :string, :required, "Event ID to add question to"
        api.param :form, "question", :Question, :required, "Question object to add to event"
        api.param :form, "options", :integer, :optional, "Number of options for single/multiple choice surveys. Options will be alphabetically orderd. Maximum is 26."
        api.param :form, "duration", :integer, :optional, "Duration of the running survey in seconds. Supply 0 for open end surveys. Omit to use user's preference"
        ApiController::add_auth_token_parameter(api)
        response :not_found
        response :unprocessable_entity
        response :unauthorized
        response :forbidden
  end

  # GET /events/:id/export
  def export
    @event ||= Event.find_by_id_or_token(params[:id])

    check_access
    return if performed?

    csv_data = CSV.generate col_sep: "\t", quote_char: '"', force_quotes: true  do |csv|
      # header row
      csv << ['Survey ID', 'Question', 'Question Type', 'Question Options', 'Voter ID', 'Survey Start', 'Survey End', 'Answer']

      # survey objects
      @event.surveys.map(&:service).each do |survey|
        # raw results
        results = survey.raw_results
        options_s = nil

        if survey.respond_to?(:options_s)
          options_s = survey.options_s
        end

        results.each do |result|
          csv << [
            survey.id,
            survey.name,
            survey.type,
            options_s,
            result.voter_id,
            survey.starts,
            survey.ends,
            result.answer
          ]
        end
      end
    end

    send_data csv_data, :type => 'text/csv; charset=utf-8; header=present', :filename => 'PINGO_surveys_'+@event.token+'_'+Time.current.to_s.tr(" ", "_")+'.csv'
  end
  
  swagger_model :Event do
        description "An Event (aka Session) object."
        property "name", :string, :optional, "Event name/title"
        property "description", :string, :optional, "Event description"
        property "mathjax", :boolean, :optional, "Whether this is a MathJax enabled event."
  end

  protected
  def event_params
    params.require(:event).permit(:name, :description, :mathjax, :collaborators_form, :custom_locale)
  end

  def check_access
    render text: t("messages.no_access_to_session"), status: :forbidden and return  if !@event.nil? && !current_user.admin && @event.user != current_user && !@event.collaborators.include?(current_user)
  end
end
