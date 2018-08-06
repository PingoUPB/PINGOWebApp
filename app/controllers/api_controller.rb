class ApiController < ApplicationController
  include ApplicationHelper
  
  before_action :authenticate_user_from_token!, :except => [:get_auth_token, :check_auth_token, :question_types, :duration_choices]
  before_action :authenticate_user!, :except => [:get_auth_token, :check_auth_token, :question_types, :duration_choices]

  INVALID_TOKEN = "invalid"
  EMPTY_OPTIONS = [""]

  def get_auth_token # used for PINGO remote and ppt app
    resource = User.find_for_database_authentication(email: params[:email])
    unless resource
      render json: {authentication_token: INVALID_TOKEN}
      return
    end

    if resource.valid_password?(params[:password])
      resource.ensure_authentication_token! #make sure the user has a token generated
      resource.save
      render json: {authentication_token: resource.authentication_token}
    else
      render json: {authentication_token: INVALID_TOKEN}
    end
  end


  def check_auth_token # used for PINGO remote and ppt app
    unless params[:auth_token]
      render json: {valid: false}
      return
    end
    if User.where(authentication_token: params[:auth_token]).first
      render json: {valid: true}
    else
      render json: {valid: false}
    end
  end

  def save_ppt_settings
    u = current_user
    fn = params[:file].to_s.gsub(".","_")
    sn = params[:session]
    hash = u.ppt_settings[sn] ? u.ppt_settings[sn] : {}
    hash = hash.merge({fn => params[:json_hash]})
    u.update_attributes(ppt_settings: u.ppt_settings.merge(sn=>hash))
    render json: u.reload, only: [:ppt_settings]
  end

  def save_question
    u = current_user
    slidesettings = params[:slide_hash]
    @question = Question.new
    if slidesettings["questionID"] 
        @question = u.questions.find(slidesettings["questionID"])
    end
    @question.user = u
    @question.name = slidesettings["questionTitle"]
    @question.question_options.clear
    if slidesettings["answerOptions"]
      slidesettings["answerOptions"].each do |option|
        @question.question_options.build(name: option, correct: false)
      end
    end
    @question.type = slidesettings["questionType"]
    @question.save
    render json: @question
  end

  def load_ppt_settings
    u = current_user
    fn = params[:file].to_s.gsub(".","_")
    render json: u.ppt_settings[params[:session]][fn]
  end

  def delete_ppt_settings
    u = current_user
    fn = params[:file].to_s.gsub(".","_")
    u.update_attributes(ppt_settings: u.ppt_settings[params[:session]].except(fn))
    render json: u.reload, only: [:ppt_settings]
  end

  def load_ppt_list
    u = current_user
    list = []
    if u.ppt_settings[params[:session]]
      list = u.ppt_settings[params[:session]].keys
    end
    render json: list
  end

  def question_types # used for PINGO remote
    render json: {question_types: [{type: "single",
                                    name_de: I18n.t("type.single", locale: :de),
                                    name_en: I18n.t("type.single", locale: :en),
                                    options: ANSWER_CHOICES,
                                    options_de: EMPTY_OPTIONS,
                                    options_en: EMPTY_OPTIONS},
                                   {type: "multi",
                                    name_de: I18n.t("type.multi", locale: :de),
                                    name_en: I18n.t("type.multi", locale: :en),
                                    options: ANSWER_CHOICES,
                                    options_de: EMPTY_OPTIONS,
                                    options_en: EMPTY_OPTIONS},
                                   {type: "text",
                                    name_de: I18n.t("type.text", locale: :de),
                                    name_en: I18n.t("type.text", locale: :en),
                                    options: TEXT_CHOICES,
                                    options_de: text_choices(:de).map(&:first),
                                    options_en: text_choices(:en).map(&:first)},
                                   {type: "number",
                                    name_de: I18n.t("type.number", locale: :de),
                                    name_en: I18n.t("type.number", locale: :en),
                                    options: EMPTY_OPTIONS,
                                    options_de: EMPTY_OPTIONS,
                                    options_en: EMPTY_OPTIONS}
    ]}
  end

  # /api/me.json
  def me 
    #render json: current_user, only: [:wants_sound, :quick_start_settings], methods: [:name, :contacts]
    render json: current_user.to_json(only: [:wants_sound, :quick_start_settings], include: {:contacts => {only: [:email], methods: [:id_as_string, :name]}})
  end



  def duration_choices
    # drop(1) because without countdown is not supported by PINGO remote
    render json: {duration_choices: DURATION_CHOICES.drop(1)}
  end

  ### for collaborators:

  def find_user_by_email
    head :precondition_failed and return if params[:email].empty?
    email = params[:email].match(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i).try(:to_s)
    head :precondition_failed and return unless email

    user = User.where(email: email).first
    if user && current_user != user
      render json: user.to_json(only: [:email, :id], methods: [:name, :id_as_string])
    else
      head :not_found
    end
  end
end
