class QuestionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_access, except: [:index, :new, :create, :show, :add_to_own, :import, :export, :upload, :share]

  def index
    if params[:public]
      @questions = Question.where(public:true)
    elsif params[:shared]  
      @questions = current_user.shared_questions
      unless @questions.any?
        @questions = current_user.questions
        params.delete :shared
      end
    else
      @questions = current_user.questions.desc(:created_at)
      @questions = Question.all.desc(:created_at) if(params[:all] && current_user.admin?)
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
      @questions = @questions.tagged_with(params[:tag])

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
      format.json { render json: @questions.uniq.map(&:service), except: [:user_id] }
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
    @question_match = MatchQuestion.new.tap { |q| q.answer_pairs.build }
    @question_order = OrderQuestion.new.tap { |q| q.order_options.build }
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
        format.json { render text: "" }
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
        format.json { render text: "" }
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

    if @question.has_order_options?
      votesString = ""
      for index in 1..@question.order_options.length
        if index == @question.order_options.length
          votesString += "0"
        else
          votesString += "0,"
        end
      end
      @question.order_options.each do |option|
        option.votes = votesString
      end
    end

    # shitty work-around: Don't know why, but the first answer_pair doesn't seem to get into
    # the params[:question][:answer_pairs_attributes] but in the params[:question][:answer_pair].
    # So we have to get it out of there and into the right place.
    if params[:question][:answer_pair] && @question.has_answer_pairs?
      @question.answer_pairs << AnswerPair.new(:answer1 => params[:question][:answer_pair][:answer1].to_s, :answer2 => params[:question][:answer_pair][:answer2].to_s, :correct => true)
    end

    respond_to do |format|
      if @question.save
        @event = Event.find_by_id_or_token(params[:redirect_to_session]) if params[:redirect_to_session]
        if params[:also_start_question] == "true"
          @survey = @question.to_survey
          @survey.event = @event
          duration = @event.default_question_duration
          @survey.save
          @survey.start!(duration)
          publish_push_notification("sess"+@survey.event.token.to_s, {:type => "status_change", :payload => "started", "timestamp" => Time.new})
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
    @question.destroy

    respond_to do |format|
      format.html { redirect_to questions_path }
      format.json { head :ok }
    end
  end

  def clone
    original_question = Question.find(params[:id])
    @question_duplicate = Question.new_from_existing(original_question)
    @question_duplicate.user = current_user

    respond_to do |format|
      if @question_duplicate.save
        format.html { redirect_to (questions_path), notice: t("messages.question_successfully_duplicated") }
        format.json { render json: @question_duplicate, status: :created, location: @question_duplicate }
      else
        format.html { render action: "show" }
        format.json { render json: @question_duplicate.errors, status: :unprocessable_entity }
      end
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
        question.user == current_user
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
      current_user.contacts.concat(share_user) unless current_user.contacts.include?(share_user)
      redirect_to questions_path, notice: t("messages.question_successfully_updated")
    else
      redirect_to questions_path, alert: t("messages.select_questions_to_share")
    end
  end

  def import

  end

  def upload
    extension, importer = get_parser params[:import_type]
    errors = importer.import(params[:file], current_user, params[:question][:tags] || "")
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
        return "txt", GiftTxtParser.new
      when "ilias"
        return "xml", IliasParser.new
      else
        # Fehler
    end
  end

  def set_js_tags
    if params["single_question"] && params["single_question"][:tags]
      params[:question][:tags] = params["single_question"][:tags]
    elsif params["multi_question"] && params["multi_question"][:tags]
      params[:question][:tags] = params["multi_question"][:tags]
    elsif params["text_question"] && params["text_question"][:tags]
      params[:question][:tags] = params["text_question"][:tags]
    elsif params["number_question"] && params["number_question"][:tags]
      params[:question][:tags] = params["number_question"][:tags]
    elsif params["match_question"] && params["match_question"][:tags]
      params[:question][:tags] = params["match_question"][:tags]
    elsif params["order_question"] && params["order_question"][:tags]
      params[:question][:tags] = params["order_question"][:tags]
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
    params.require(:question).permit(:name, :type, :description, :tags, :public, :collaborators_form, question_options_attributes: [:name, :correct, :id, :_destroy], answer_pairs_attributes: [:answer1, :answer2, :correct, :id, :_destroy], order_options_attributes: [:name, :position, :id, :_destroy])
  end

end
