require 'spec_helper'

describe EventsController do

  def create_test_session
    @survey = FactoryGirl.create(:survey)
    @event = @survey.event
    @user = @event.user
  end

  def set_browser_locale(locale)
    request.env['HTTP_ACCEPT_LANGUAGE'] = "#{locale};q=1.0"
  end

  describe "show" do
    render_views

    it "displays the lecturers session page in his German browser locale" do
      pending
      create_test_session
      sign_in @user

      set_browser_locale("de") # does not work
      get :show, id: @event.token
      assert_select "html[lang=?]", /de/
    end

    it "displays the lecturers session page in his English browser locale" do
      pending
      create_test_session
      sign_in @user

      set_browser_locale("en") # does not work
      get :show, id: @event.token
      assert_select "html[lang=?]", /en/
    end

    it "displays the lecturers session page in the session locale, if set" do
      create_test_session
      sign_in @user

      set_browser_locale("en")

      @event.update_attribute(:custom_locale, "de")

      get :show, id: @event.token
      assert_select "html[lang=?]", /de/
    end
  end


end
