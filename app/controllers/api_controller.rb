class ApiController < ApplicationController
  include ApplicationHelper

  INVALID_TOKEN = "invalid"
  EMPTY_OPTIONS = [""]

  def get_auth_token # used for PINGO remote
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


  def check_auth_token # used for PINGO remote
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

  def duration_choices
    # drop(1) because without countdown is not supported by PINGO remote
    render json: {duration_choices: DURATION_CHOICES.drop(1)}
  end
end