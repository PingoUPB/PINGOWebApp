class QuestionsController < ApplicationController
  before_action :authenticate_user_from_token!
  before_action :authenticate_user!
  before_action :check_access, except: [:index, :new, :create, :show, :add_to_own, :import, :export, :upload, :share]

  def index
    if params[:public]
      @questions = Question.where(public: true)
    elsif params[:shared]
      @questions = current_user.shared_questions
      unless @questions.any?
        @questions = current_user.questions
        params.delete :shared
      end
    else
      @questions = current_user.questions.desc(:created_at)
      @questions = Question.order_by([:created_at, :desc]) if(params[:all] && current_user.admin?)
    end

    if params[:q_type] # TODO: refactor maybe? soooo long :(
      q_before = @questions
      if params[:q_type] == "choice"
        choice_types = ["single", "multi"]
        @questions = @questions.in(type: choice_types)
        if params[:public]
          @tags = Question.public_question_tags(choice_types)
        elsif params[:shared]
          @tags = current_user.shared_question_tags(choice_types)
        else
          @tags = current_user.question_tags(choice_types)
        end
      elsif Question.question_types.include?(params[:q_type])
        @questions = @questions.where(type: params[:q_type])
        if params[:public]
          @tags = Question.public_question_tags([params[:q_type]])
        elsif params[:shared]
          @tags = current_user.shared_question_tags([params[:q_type]])
        else
          @tags = current_user.question_tags([params[:q_type]])
        end
        @tags = current_user.question_tags([params[:q_type]])
      end

      unless @questions.any?
        params[:q_type] = nil
        @questions = q_before
        if params[:public]
          @tags = Question.public_question_tags
        elsif params[:shared]
          @tags = current_user.shared_question_tags
        else
          @tags = current_user.question_tags
        end
      end
    else
      if params[:public]
        @tags = Question.public_question_tags
      elsif params[:shared]
        @tags = current_user.shared_question_tags
      else
        @tags = current_user.question_tags
      end
    end

    if params[:tag]
      q_before = @questions
      QuestionTag.find(params[:tag])
      #if params[:public]
      #  @questions = q_tag.tagged.where(public: true)
      #else
      #  @questions = q_tag.tagged.where(tags: params[:tag]).select { |q| q.can_be_accessed_by?(current_user)}
      #end
      @questions = @questions.where(tags: params[:tag])

      unless @questions.any?
        params[:tag] = nil
        @questions = q_before
      end
    end

    if params[:recently_commented]
      q_before = @questions
      @questions = @questions.recently_commented

      unless @questions.any?
        params[:recently_commented] = nil
        @questions = q_before
      end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: (@questions + current_user.shared_questions).uniq.map(&:service), except: [:user_id] }
    end
  end

  def show
    @question = Question.find(params[:id]).service
    unless @question.public
     check_access
    end
  end

  def new
    @question_single = SingleChoiceQuestion.new.tap { |q| q.question_options.build }
    @question_multi = MultipleChoiceQuestion.new.tap { |q| q.question_options.build }
    @question_text = TextQuestion.new
    @question_number = NumberQuestion.new  #refactor this maybe?
  end

  def edit

  end

  def update
    set_js_tags

    if params[:options] && @question.has_settings?
      @question.add_setting("answers", params[:options])
    end

    respond_to do |format|
      if @question.update_attributes(question_params)
        current_user.contacts.concat (@question.collaborators - current_user.contacts)
        format.html { redirect_to question_path(@question), notice: t("messages.question_successfully_updated") }
        format.json { render plain: "" }
      else
        format.html { render action: "edit" }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  def transform
    respond_to do |format|
      if @question.kind_of?(ChoiceQuestion) && @question.transform
        format.html { redirect_to question_path(@question), notice: t("messages.question_successfully_updated") }
        format.json { render plain: "" }
      else
        format.html { render action: "edit" }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  def create
    set_js_tags
    @question = Question.new(question_params).service
    @question.user = current_user

    if params[:options] && @question.has_settings?
      @question.add_setting("answers", params[:options])
    end

    respond_to do |format|
      if @question.save
        @event = Event.find_by_id_or_token(params[:redirect_to_session]) if params[:redirect_to_session] && !params[:redirect_to_session].blank?
        if params[:also_start_question] == "true"
          @survey = @question.to_survey
          @survey.event = @event
          duration = @event.default_question_duration
          @survey.save
          @survey.start!(duration)
          publish_push_notification("/sess/"+@survey.event.token.to_s, {:type => "status_change", :payload => "started", "timestamp" => Time.new})
          start_countdown_worker(@survey.id) if duration > 0
        end
        format.html { redirect_to (@event || questions_path), notice: t("messages.question_successfully_created") }
        format.json { render json: @question, status: :created, location: @question }
      else
        format.html { render action: "edit" }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @question.destroy if @question.user == current_user || current_user.admin?

    respond_to do |format|
      format.html { redirect_to questions_path }
      format.json { head :ok }
    end
  end

  def add_to_own
    original_question = Question.find(params[:id])

    @question = Question.new_from_existing(original_question)
    @question.user = current_user

    respond_to do |format|
      if @question.save
        format.html { redirect_to questions_path, notice: t("messages.question_successfully_added") }
        format.json { render json: @question, status: :created, location: @question }
      else
        format.html { render action: "show" }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  def export
    unless params[:question_ids].blank?
      questions = params[:question_ids].map do |id|
        Question.find(id).service
      end.select do |question|
        question.can_be_accessed_by?(current_user)
      end
      extension, exporter = get_parser params[:export_type]
      exported_string = exporter.export questions
      send_data exported_string, type: Mime::Type.lookup_by_extension(extension), filename: 'Pingo_Questions.'+extension
    else
      redirect_to questions_path, alert: t("messages.select_questions_for_export")
    end
  end

  def share
    unless params[:question_ids].blank? && params[:share_user_id].blank?
      questions = params[:question_ids].map do |id|
        Question.find(id).service
      end.select do |question|
        question.user == current_user
      end
      share_user = User.find(params[:share_user_id])
      questions.each do |q|
        q.collaborators << share_user
      end
      current_user.contacts.append(share_user) unless current_user.contacts.include?(share_user)
      redirect_to questions_path, notice: t("messages.question_successfully_updated")
    else
      redirect_to questions_path, alert: t("messages.select_questions_to_share")
    end
  end

  def import

  end

  def upload
    extension, importer = get_parser params[:import_type]
    errors = importer.import(params[:file], current_user, (params[:question][:tags] || "").split(","))
    unless errors[0].empty?
      @errors = errors[0]
      @successes = errors[1]
      render "import"
    else
      redirect_to questions_path, notice: t("messages.question_successfully_added")
    end
  end

  protected
  def get_parser(p)
    case p
      when "csv"
        return "csv", CsvParser.new
      when "aiken"
        return "txt", AikenParser.new
      when "moodle_xml"
        return "xml", MoodleXmlParser.new
      when "gift"
        return "gift", GiftImporter.new
      when "ilias"
        return "xml", IliasParser.new
      else
        # Fehler
    end
  end

  def set_js_tags
    if params["single_question"] && params["single_question"][:tags]
      params[:question][:tags] = params["single_question"][:tags].split(",")
      puts params[:question][:tags]
    elsif params["multi_question"] && params["multi_question"][:tags]
      params[:question][:tags] = params["multi_question"][:tags].split(",")
    elsif params["text_question"] && params["text_question"][:tags]
      params[:question][:tags] = params["text_question"][:tags].split(",")
    elsif params["number_question"] && params["number_question"][:tags]
      params[:question][:tags] = params["number_question"][:tags].split(",")
    end
  end

  def check_access
    @question = Question.find(params[:id]).service

    unless !@question.nil? && @question.can_be_accessed_by?(current_user)
      flash[:error] = t("messages.no_access_to_question")
      redirect_to questions_path, status: :forbidden and return false
    end
    true
  end

  def question_params
    params.require(:question).permit! #(:name, :type, :description, :tags, :public, :collaborators_form, question_options_attributes: [:name, :correct, :id, :_destroy])
  end
end
