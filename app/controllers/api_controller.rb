class ApiController < ApplicationController
  include ApplicationHelper
  before_filter :authenticate_user!, :except => [:get_auth_token, :check_auth_token, :question_types, :duration_choices]

  INVALID_TOKEN = "invalid"
  EMPTY_OPTIONS = [""]
  
  swagger_controller :api, "General API methods"
  
  def self.add_auth_token_parameter(api, as_query_param = false)
    api.param((as_query_param ? :query : :form), "auth_token", :string, :required, "Authentication token (see `api/get_auth_token`)")
  end

  def get_auth_token # used for PINGO remote and ppt app
    resource = User.find_for_database_authentication(email: params[:email])
    unless resource
      render json: {authentication_token: INVALID_TOKEN}
      return
    end

    if resource.valid_password?(params[:password])
      resource.ensure_authentication_token! #make sure the user has a token generated
      render json: {authentication_token: resource.authentication_token}
    else
      render json: {authentication_token: INVALID_TOKEN}
    end
  end
  
  swagger_api :get_auth_token do
    summary "Gets an auth token for initial login."
    notes "returns '#{INVALID_TOKEN}' if an error occured (such as invalid user/password combination)"
    param :form, "email", :string, :required
    param :form, "password", :string, :required
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
  
  swagger_api :check_auth_token do
    summary "Checks whether the supplied API token is valid."
    notes "returns a JSON hash with a 'valid' key being either true or false."
    param :form, "auth_token", :string, :required
  end
  
  # :nocov:
  def save_ppt_settings
    u = current_user
    fn = params[:file].to_s.gsub(".","_")
    sn = params[:session]
    hash = u.ppt_settings[sn] ? u.ppt_settings[sn] : {}
    hash = hash.merge({fn => params[:json_hash]})
    u.update_attributes(ppt_settings: u.ppt_settings.merge(sn=>hash))
    render json: u.reload, only: [:ppt_settings]
  end
  # :nocov:

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

  # :nocov:
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
  # :nocov:

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
  
  swagger_api :question_types do
    summary "Returns a list of questions types with their names in German and English."
  end

  def duration_choices
    # drop(1) because without countdown is not supported by PINGO remote
    render json: {duration_choices: DURATION_CHOICES.drop(1)}
  end
  
  swagger_api :duration_choices do
    summary "Returns a list of default PINGO duration choices."
  end


  ### for collaborators:

  def find_user_by_email
    head :precondition_failed and return if params[:email].empty?
    email = params[:email].match(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i).try(:to_s)
    head :precondition_failed and return unless email

    user = User.where(email: email).first
    if user && current_user != user
      render json: user, only: [:email], methods: [:name, :id]
    else
      head :not_found
    end
  end
  
  swagger_api :find_user_by_email do |api|
      summary "Looks up a user id and name for a given email address. Useful in combination with sharing events and sharing questions."
      ApiController::add_auth_token_parameter(api, true)
      api.param :query, "email", :string, :required
      response :unauthorized
      response :not_found
      response :precondition_failed
  end
  
end
