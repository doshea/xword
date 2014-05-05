Xword::Application.routes.draw do
  root to: 'pages#home'
  get '/welcome' => 'pages#welcome'

  resources :users, only: [:new, :create, :show, :update] do
    collection do
      get :account
      get :forgot_password
      get 'reset_password/:password_reset_token' => 'users#reset_password', as: 'reset_password'
      post :send_password_reset
      post :change_password
      post :resetter
    end
  end

  resources :crosswords, except: [:index, :destroy] do
    member do
      get :publish
      post 'team' => 'crosswords#create_team', as: 'create_team'
      post :favorite
      delete :unfavorite
      get 'team/:key' => 'crosswords#team', as: 'team'
      get 'solution_choice'
      post :add_potential_word
      delete 'remove_potential_word/:potential_word_id' => 'crosswords#remove_potential_word', as: 'remove_potential_word'
    end
    collection do
      post :batch
    end
  end

  resources :clues, only: [:show, :update]
  resources :words, only: [:show] do
    collection do
      post :match
    end
  end
  resources :comments, only: [:destroy] do
    member do
      post :add_comment, as: 'add'
      post :reply, as: :reply_to
    end
  end

  resources :cells, only: [:update] do
    member do
      put :toggle_void
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
  get '/nytimes' => 'pages#nytimes'

  namespace :admin do
    get :email
    post :test_emails
    get :clone_user, to: :cloning_tank, as: :cloning_tank
    post :user_search
    post :clone_user
    get :wine_comment

    resources :crosswords, only: [:index, :edit, :update, :destroy]
    resources :clues, only: [:index, :edit, :update, :destroy]
    resources :words, only: [:index, :edit, :update, :destroy]
    resources :comments, only: [:index, :edit, :update, :destroy]
    resources :users, only: [:index, :edit, :update, :destroy]
    resources :solutions, only: [:index, :edit, :update, :destroy]
  end

  namespace :create do
    get :dashboard
  end

  namespace :api do
    get :history
  end

end
