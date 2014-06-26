require 'factory_girl'

FactoryGirl.define do
  factory :user do
    first_name 'Testy'
    last_name 'McUserton'
    email 'example@example.com'
    password 'please'
    password_confirmation 'please'
    organization "test orga"
    faculty "test fac"
    chair "test chair"
    # required if the Devise Confirmable module is used
    # confirmed_at Time.now

    factory :admin do
      admin true
    end
  end

  factory :hacker, class: User do
    first_name 'Hacky'
    last_name 'McCracker'
    email 'hack@example.com'
    password 'please'
    password_confirmation 'please'
    organization "test orga"
    faculty "test fac"
    chair "test chair"
  end

  factory :event do
    name 'Test Session'
    user
  end

  factory :option do
    sequence :name do |n|
      "Option ##{n}"
    end
  end

  factory :survey do
    name 'Test survey'
    event
    type "single"
    # survey_with_options will create answer options after the survey has been created
    factory :survey_with_options do
      # options_count is declared as an ignored attribute and available in
      # attributes on the factory, as well as the callback via the evaluator
      ignore do
        options_count 4
      end

      # the after(:create) yields two values; the user instance itself and the
      # evaluator, which stores all values from the factory, including ignored
      # attributes; `create_list`'s second argument is the number of records
      # to create and we make sure the option is associated properly to the survey
      after(:create) do |survey, evaluator|
        FactoryGirl.create_list(:option, evaluator.options_count, survey: survey)
      end
    end


    factory :text_survey do
      name 'Tag cloud test survey'
      type "text"
    end

    factory :numeric_survey do
      name 'Numeric test survey'
      type "number"
    end
  end
end
