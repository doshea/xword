Xword::Application.routes.draw do
  root to: 'pages#home'
  get '/welcome' => 'pages#welcome'

  resources :users, only: [:index, :new, :create, :show, :update] do
    collection do
      get :account
      get :reset_password, to: :forgot_password
      post :reset_password
    end
  end

  resources :crosswords do
    member do
      get :publish
      post 'team' => 'crosswords#create_team', as: 'create_team'
      post :favorite
      delete :unfavorite
      get 'team/:key' => 'crosswords#team', as: 'team'
      get 'solution_choice'
    end
  end

  resources :clues, only: [:index, :show, :update]
  resources :words, only: [:index, :show]
  resources :comments, only: [:index] do
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

  get '/unauthorized' => 'pages#unauthorized'
  get '/account_required' => 'pages#account_required'
  get '/search' => 'pages#search'
  get '/live_search' => 'pages#live_search'
  get '/about' => 'pages#about'
  get '/faq' => 'pages#faq'
  get '/contact' => 'pages#contact'
  get '/stats' => 'pages#stats'
  get '/nytimes' => 'pages#nytimes'

end
