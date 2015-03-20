Xword::Application.routes.draw do
  root to: 'pages#home'
  get '/welcome' => 'pages#welcome'

  resources :cells, only: [:update] do
    member do
      put :reletter #TODO
      put :toggle_void
    end
  end

  resources :clues, only: [:show, :update]

  resources :comments, only: [:destroy] do
    member do
      post :add_comment, as: 'add'
      post :reply, as: :reply_to
    end
  end

  resources :crosswords, except: [:index, :destroy] do
    member do
      get :publish
      post 'team' => 'crosswords#create_team', as: 'create_team'
      post :favorite
      delete 'favorite' => 'crosswords#unfavorite'
      get 'team/:key' => 'crosswords#team', as: 'team'
      get 'solution_choice'
    end
    collection do
      post :batch
    end
  end

  resources :unpublished_crosswords do
    member do
      patch :publish
      patch :add_potential_word
      patch :update_letters
      delete 'remove_potential_word/:word' => 'unpublished_crosswords#remove_potential_word', as: 'remove_potential_word'
    end
  end

  resources :solutions, only: [:show, :update] do
    member do
      post :get_incorrect
      post :check_correctness
      patch :team_update
      post :join_team
      post :leave_team
      post :roll_call
      post :send_team_chat
      post :show_team_clue
      delete :destroy, as: :delete
    end
  end

  resources :users, only: [:new, :create, :show, :update] do
    member do
      # TODO
      # get :favorites 
    end
    collection do
      get :account
      get :forgot_password
      get 'reset_password/:password_reset_token' => 'users#reset_password', as: 'reset_password'
      post :send_password_reset
      post :change_password
      post :resetter
    end
  end
  
  resources :words, only: [:show] do
    collection do
      post :match
    end
  end

  namespace :account do
    get '/', to: :show
    patch :update
    patch :change_password
    
    get :forgot
    get :forgot_username
    get :forgot_password
    get :reset_password

    get :verify
    get :verified
  end

  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  delete '/logout' => 'sessions#destroy'

  get '/error' => 'pages#error'
  get '/unauthorized' => 'pages#unauthorized'
  get '/account_required' => 'pages#account_required'
  get '/search' => 'pages#search'
  get '/live_search' => 'pages#live_search'
  get '/about' => 'pages#about'
  get '/faq' => 'pages#faq'
  get '/contact' => 'pages#contact'
  get '/stats' => 'pages#stats'
  get '/nytimes' => 'pages#nytimes' #TODO decide if this will be its own page or not
  get '/user_made' => 'pages#user_made' #TODO decide if this will be its own page or not

  namespace :admin do
    get :email
    post :test_emails
    get :clone_user, to: :cloning_tank, as: :cloning_tank
    post :user_search
    post :clone_user
    get :wine_comment

    resources :crosswords, only: [:index, :edit, :update, :destroy] do
      patch :generate_preview, on: :member
    end
    resources :clues, only: [:index, :edit, :update, :destroy]
    resources :words, only: [:index, :edit, :update, :destroy]
    resources :comments, only: [:index, :edit, :update, :destroy]
    resources :users, only: [:index, :edit, :update, :destroy]
    resources :solutions, only: [:index, :edit, :update, :destroy]
  end

  namespace :create do
    get :dashboard
  end

  namespace :api, defaults: {format: :json} do
    get '/nyt_source/:year/:month/:day' => :nyt_source
    get '/nyt/:year/:month/:day' => :nyt
    get :nyt
    namespace :users do
      get '/' => :index
      get :search
    end
    namespace :crosswords do
      get :search
      get :simple
    end
  end

end
