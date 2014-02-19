Eclickr::Application.routes.draw do

  root :to => "home#index"

  post "find" => "events#find"
  post "vote" => "surveys#vote"
  post "quick_start" => "events#quick_start"

  # API routes
  post "api/get_auth_token" => "api#get_auth_token"
  post "api/check_auth_token" => "api#check_auth_token"
  get "api/question_types" => "api#question_types"
  get "api/duration_choices" => "api#duration_choices"
  
  get "api/find_user_by_email" => "api#find_user_by_email"

  get "stats" => "home#stats", as: :stats
  get "switch_view" => "home#switch_view"


  get "api/:cmd" => "surveys#api"

  post "vote-test" => "surveys#vote_test"

  devise_for :users, :controllers => {:registrations => 'settings'}

  devise_scope :user do
    post "users/reset_api_token" => "settings#reset_auth_token", as: :reset_auth_token
  end


  resources :events do
    member do
      post "quick_start" => "surveys#quick_start"
      post "add_question" => "events#add_question"
      post "exit_question" => "surveys#exit_question"
      get "connected" => "events#connected_users"
      get "export"
    end
    resources :surveys do
      member do
        post 'start'
        post 'stop'
        post 'repeat'
        get 'changed'
        get 'changed_aggregated'
        get 'results'
      end
    end
  end

  resources :questions do
    member do
      post 'add_to_own'
    end
    resources :question_comments, only: [:create, :destroy, :index]
    collection do
      post "export"
      get 'import'
      post 'upload'
    end
  end

  get "invitations/new", :as => "invitation"
  post "invitations/deliver", :as => "deliver_invitation"

  mount Maktoub::Engine => "/" # mounts newsletter engine at /newsletters

  namespace :admin do
    resources :users
    get 'voting_analytics' => 'users#voting_analytics'
  end

  # for survey quicklinks like "/1234" - must be last route.
  get ":id" => "surveys#participate", :constraints => {:id => /[0-9]+/}, :as => :participate

  mount Amnesia::Application.new => "/amnesia" if defined?(Amnesia)

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
