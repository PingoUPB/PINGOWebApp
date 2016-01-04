class SurveysController < ApplicationController
  before_filter :authenticate_user!, :except => [:vote, :vote_test, :participate]

  layout :detect_browser #, :only => [:participate, :find]

  # GET /events/:event_id/surveys
  # GET /events/:event_id/surveys.json
  def index
    @event = Event.find_by_id_or_token(params[:event_id])
    render text: t("messages.no_access_to_session"), status: :forbidden and return  if !@event.nil? && !current_user.admin && @event.user != current_user && !@event.collaborators.include?(current_user)
    
    return if performed?
    
    @surveys = @event.surveys.display_fields.desc(:created_at)

    respond_to do |format|
      format.html { render partial: "events/surveys_table", locals: {event: @event} }
      format.json { send_data @surveys.to_json, 
                              :type => 'json; charset=utf-8; header=present', 
                              :filename => 'PINGO_surveys_'+@event.token+'_'+Time.current.to_s.tr(" ", "_")+'.json' 
                  }
    end
  end

  # GET /events/:event_id/surveys/1
  # GET /events/:event_id/surveys/1.json
  def show
    @survey = Survey.display_fields.find(params[:id]).service
    check_access
    return if performed?

    respond_to do |format|
      set_locale_for_event_or_survey
      format.html {
        if params[:remote_view] == "true"
         render "surveys/show_remote", layout: false
        elsif params[:ppt_view] == "true"
          render "surveys/show_ppt", layout: false
        else
          @event = @survey.event
          @surveys = @event.surveys.display_fields.desc(:created_at) #map(:service)
          @load_survey = @survey

          render "events/show"
        end
      }
      format.js
      format.json { render json: @survey }
    end
  end

  # GET /events/:event_id/surveys/new
  # GET /events/:event_id/surveys/new.json
  def new
    @survey = Survey.new
    @survey.options.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @survey }
    end
  end

  # GET /events/:event_id/surveys/1/edit
  def edit
    @survey = Survey.display_fields.find(params[:id]).service
  end

  # POST /events/:event_id/surveys
  # POST /events/:event_id/surveys.json
  def create
    @event = Event.find_by_id_or_token(params[:event_id])
    @survey = Survey.new(survey_params)
    @survey.event = @event

    render :text => t("messages.no_access_to_session"), :status => :forbidden and return  if !@event.nil? && !current_user.admin && @event.user != current_user

    respond_to do |format|
      if @survey.save
        format.html { redirect_to event_survey_path(@survey.event, @survey), notice: t("messages.survey_successfully_created") }
        format.json { render json: @survey, status: :created, location: @survey }
      else
        format.html { render action: "new" }
        format.json { render json: @survey.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /events/:event_id/surveys/1
  # PUT /events/:event_id/surveys/1.json
  def update
    @survey = Survey.find(params[:id]).service

    check_access
    return if performed?

    respond_to do |format|
      if @survey.update_attributes(survey_params)
        format.html { redirect_to event_survey_path(@survey.event, @survey), notice: t("messages.survey_successfully_updated") }
        format.json { render :text => "" }
      else
        format.html { render action: "edit" }
        format.json { render json: @survey.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/:event_id/surveys/1
  # DELETE /events/:event_id/surveys/1.json
  def destroy
    @survey = Survey.find(params[:id])

    check_access
    return if performed?

    publish_push_notification("s"+@survey.id.to_s, {:type => "status_change", :payload => "stopped", "timestamp" => Time.new})

    @survey.destroy

    respond_to do |format|
      format.html { redirect_to event_path(@survey.event) }
      format.json { head :ok }
    end
  end


  # GET /:id
  def participate
    @event = Rails.cache.read("Events/"+params[:id])
    unless @event
      begin
        pprint "getting event from DB (no cache)"
        @event = Event.find_by_id_or_token(params[:id])
        Rails.cache.write("Events/"+params[:id], @event, :expires_in => 5.seconds)
      rescue ; end    #rescue errors like BSON::InvalidObjectId (if people enter neither a token nor a proper Mongo ID)
    end

    respond_to do |format|
      format.html { #normal view
        redirect_to root_path, alert: t("messages.survey_not_found") and return if @event.nil?
        @survey = Rails.cache.read("last_survey/"+params[:id])
        unless @survey
          pprint "getting survey from DB (no cache)"
          @survey = @event.latest_survey("participate").try(:service)
          Rails.cache.write("last_survey/"+params[:id], @survey, :expires_in => 1.seconds)
        end
      }
      format.json { render json: @event.state } # state info to update view if neccessary
    end
  end

  # POST /events/:event_id/surveys/1/start
  def start
    @survey = Survey.display_fields.find(params[:id]).service
    @event = @survey.event
    check_access
    return if performed?

    if(is_numeric?(params[:stoptime]))
      @survey.start!(params[:stoptime].to_i)
      if params[:stoptime].to_i > 0
        publish_push_notification("s"+@survey.id.to_s, {:type => "status_change", :payload => "started_with_end", "timestamp" => Time.new})
        start_countdown_worker(@survey.id)
      else
        publish_push_notification("s"+@survey.id.to_s, {:type => "status_change", :payload => "started", "timestamp" => Time.new})
      end
    else
      @survey.start!
      publish_push_notification("s"+@survey.id.to_s, {:type => "status_change", :payload => "started", "timestamp" => Time.new})
    end
    respond_to do |format|
      set_locale_for_event_or_survey
      format.html { redirect_to event_survey_path(@survey.event, @survey), notice: t('messages.survey_started') }
      format.js { render "events/add_question" }
    end
  end

  # POST /events/:event_id/surveys/1/stop
  def stop
    @survey = Survey.display_fields.find(params[:id]).service
    @event = @survey.event
    check_access
    return if performed?

    if(is_numeric?(params[:stoptime]) && params[:stoptime].to_i > 0)
      @survey.stop!(params[:stoptime].to_i)
      publish_push_notification("s"+@survey.id.to_s, {:type => "status_change", :payload => "stop_scheduled", "time" => @survey.time_left(true), "timestamp" => Time.new})
      start_countdown_worker(@survey.id)
      flash_notice = t('messages.survey_stop_scheduled')
    else
      @survey.stop!
      publish_push_notification("s"+@survey.id.to_s, {:type => "status_change", :payload => "stopped", "timestamp" => Time.new})
      flash_notice = t('messages.survey_stopped')
    end
    respond_to do |format|
      set_locale_for_event_or_survey
      format.html { redirect_to event_survey_path(@survey.event, @survey), notice: flash_notice }
      format.js { render "events/add_question" }
    end
  end

  # POST /events/:event_id/surveys/1/repeat
  def repeat
    @event = Event.find_by_id_or_token(params[:event_id])
    original_survey = Survey.find(params[:id])

    render :text => t("messages.no_access_to_session") and return  if !@event.nil? && !current_user.admin && @event.user != current_user

    @survey = Survey.new
    @survey.event = @event
    @survey.name = original_survey.name
    @survey.quick = true
    original_survey.options.map do |option|
      @survey.options.new(name: option.name, correct: option.correct)
    end
    @survey.type = original_survey.type
    @survey.settings = original_survey.settings
    @survey.original_survey = original_survey
    duration = (is_numeric?(params[:duration]) ? params[:duration].to_i : 0)

    respond_to do |format|
      set_locale_for_event_or_survey
      if @survey.save
        @survey.service.start!(duration)
        publish_push_notification("sess"+@survey.event.token.to_s, {:type => "status_change", :payload => "started", "timestamp" => Time.new})
        start_countdown_worker(@survey.id) if duration > 0
        format.html { redirect_to event_path(@survey.event), notice: t("messages.survey_successfully_created") }
        format.js { render "events/add_question" }
        format.json { render json: @survey, status: :created, location: @survey }
      else
        format.html { render action: "new" }
        format.json { render json: @survey.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /vote
  def vote
    redirect_to root_path, alert: t("messages.misc_error") if params[:id].blank?

    @vid = get_or_create_voter_id
    @survey = Survey.find(params[:id]).service
    @user_just_voted = false
    redirect_to "/"+@survey.event.to_param, alert: t("messages.no_option_error") and return if (params[:option].blank? && !@survey.multi)

    if @survey.vote(@vid, params[:option])
      respond_to do |format|
        format.html {
          if @survey.has_options?
            if @survey.type == "multi"
              unless params[:option].nil?
                voted_for = "<br>"+params[:option].map { |o| ("- "+@survey.options.only(:name).find(o).name)+"<br>"}.join
              else
                voted_for = t("matrix_keys.no_answer")
              end
            else
              voted_for = @survey.options.only(:name).find(params[:option]).name
            end
          else
            if params[:option].respond_to? :each
              voted_for = "<br>- " + params[:option].reject {|o| o.blank? }.join("<br>- ") + "<br>"
            else
              voted_for = params[:option]
            end
          end
          @user_just_voted = true
          redirect_to "/"+@survey.event.to_param, notice: (t("messages.voting_ok") + " " + t("messages.voted_for", option: voted_for)).html_safe
        }
        format.json { head :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to "/"+@survey.event.to_param, alert: t("messages.already_voted") }
        format.json { render text: t("messages.already_voted") }
      end
    end
  end

  # POST vote-test
  # Regression TEST method
  def vote_test
    #variables:
    activate = true #set to false when not testing
    id = 1068
    option = "4e9abbd53ae74077f300000e"
    voter = nil # set to nil if you don't care.

    if activate
      vid = voter
      vid = get_or_create_voter_id if vid.nil?
      @survey = Survey.find(id)
      if @survey.vote_for_option(vid,option)
        respond_to do |format|
          format.html { redirect_to root_path, notice: t(voting_ok) }
          format.json { head :ok }
        end
      else
        respond_to do |format|
          format.html { redirect_to "/"+@survey.event.to_param, alert: t("messages.already_voted") }
          format.json { render text: t("messages.already_voted") }
        end
      end
    end
  end

  # POST /events/:id/quick_start
  def quick_start
    @event = Event.find_by_id_or_token(params[:id])

    render :text => t("messages.no_access_to_session") and return  if !@event.nil? && !current_user.admin && @event.user != current_user

    @survey = Survey.new
    @survey.event = @event
    # @survey.name = t("quick_survey")
    @survey.quick = true



    if Question.question_types.include?(params[:q_type])
      @survey.type = params[:q_type]
    else
      @survey.type = "single"
      params[:q_type] = "single"
    end

    @survey = @survey.service

    if params[:survey_name]
      @survey.name = params[:survey_name]
      params[:predef_options].each do |option|
        @survey.options.new(name: option)
      end
    elsif @survey.has_options?

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
      @event.update_attribute(:default_question_duration, duration)
      current_user.save!
    end

    respond_to do |format|
      if @survey.save
        @survey.service.start!(duration)
        publish_push_notification("sess"+@survey.event.token.to_s, {:type => "status_change", :payload => "started", "timestamp" => Time.new})
        start_countdown_worker(@survey.id) if duration > 0
        format.html { redirect_to event_path(@survey.event), notice: t("messages.survey_successfully_created") }
        format.js { render "events/add_question" }
        format.json { render json: @survey, status: :created, location: @survey }
      else
        format.html { render action: "new" }
        format.json { render json: @survey.errors, status: :unprocessable_entity }
      end
    end
  end

  def exit_question
    @event = Event.find_by_id_or_token(params[:id])

    render :text => t("messages.no_access_to_session") and return  if !@event.nil? && !current_user.admin && @event.user != current_user

    @survey = Survey.new
    @survey.event = @event
    @survey.quick = true
    @survey.name = t("surveys.exit_question")
    @survey.type = "single"

    options_amount = 3
    options = [t("positive"),t("neutral"),t("negative")]

    duration = (is_numeric?(params[:duration]) ? params[:duration].to_i : 300)

    (1..options_amount).each do |option|
      @survey.options.new(name: options[option-1])
    end

    respond_to do |format|
      if @survey.save
        @survey.start!(duration)
        publish_push_notification("sess"+@survey.event.token.to_s, {:type => "status_change", :payload => "started", "timestamp" => Time.new})
        start_countdown_worker(@survey.id) if duration > 0
        format.html { redirect_to event_path(@survey.event), notice: t("messages.survey_successfully_created") }
        format.js { render "events/add_question" }
        format.json { render json: @survey, status: :created, location: @survey }
      else
        format.html { render action: "new" }
        format.json { render json: @survey.errors, status: :unprocessable_entity }
      end
    end
  end

  def changed
    @survey = Survey.only(:original_survey_id, :type, :options, :voters_hash, :event_id).find(params[:id]).service
    check_access
    return if performed?

    if @survey.original_survey
      new_survey = @survey
      old_survey = new_survey.original_survey.service
      @matrix = new_survey.changed_behaviour
      @rows = []
      @cols = []
      @matrix.each do |key, value|
        # rows for old choice, column for new choice.
        @rows.push([key.first, key.first.map do |o|
          if o.is_a? Symbol
            t("matrix_keys.#{o}")
          else
            old_survey.options.find(o).name.truncate(27, separator: ' ')
          end
          end.join("+")])
        @cols.push([key.second, key.second.map do |o|
          if o.is_a? Symbol
            t("matrix_keys.#{o}")
          else
            new_survey.options.find(o).name.truncate(27, separator: ' ')
          end
          end.join("+")])
      end
      @rows.uniq!
      @cols.uniq!
      set_locale_for_event_or_survey
      render :layout => false
    else
      head :precondition_failed
    end
  end

  def changed_aggregated
    @survey = Survey.only(:original_survey_id, :type, :options, :voters_hash, :event_id).find(params[:id]).service
    check_access
    return if performed?

    if @survey.original_survey
      new_survey = @survey
      @matrix = new_survey.changed_behaviour_aggregated
      @rows = []
      @cols = []
      @matrix.each do |key, value|
        @rows.push([key.first, key.first.map do |o|
          t("matrix_keys.#{o}")
        end.join])
        @cols.push([key.second, key.second.map do |o|
          t("matrix_keys.#{o}")
        end.join])
      end
      @rows.uniq!
      @cols.uniq!
      set_locale_for_event_or_survey
      render "changed", :layout => false
    else
      head :precondition_failed
    end
  end

  def results
    @survey = Survey.only(:type, :options, :voters_hash, :event_id, :voters).find(params[:id]).service
    check_access
    return if performed?

    if params[:view_type] == "tag_cloud"
      @view_type = "text_tag_cloud_result"
    elsif params[:view_type] == "clustered_chart"
      @view_type = "number_clustered_chart_results"
    else
      @view_type = "text_table_results"
    end
    set_locale_for_event_or_survey
  end

  # :nocov:
  # GET /api
  def api
    render :json => "ERROR! no cmd" and return if params[:cmd].nil?
    if params[:cmd] == "json_results"
      render :json => "ERROR! cmd=json_results requires the paramter id" and return if params[:id].nil?
      @survey = nil
      if params[:id].length > 8
        @survey = Survey.display_fields.find(params[:id])
      else
        event = Event.find_by_id_or_token(params[:id])
        @survey = event.latest_survey if event
      end
      render :json => "ERROR! survey with id #{params[:id]} not found"  and return if @survey.nil?
      results = @survey.compact_results
      results["timestamp"] = Time.new
      render :json => results and return
    else
      render :json => "ERROR! invalid cmd" and return if params[:cmd].blank?
    end
    render :nothing => true
  end
  # :nocov:

  protected
  def survey_params
    params.require(:survey).permit(:name, :description, options_attributes: [:name, :correct, :id])
  end

  def check_access
    render :text => t("messages.no_access_to_survey"), status: :forbidden and return  if !@survey.nil? && !current_user.admin && @survey.user != current_user && !@survey.collaborators.include?(current_user)
  end
end
