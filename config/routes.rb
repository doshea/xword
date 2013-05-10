Xword::Application.routes.draw do
  root :to => 'pages#home'
  get '/welcome' => 'pages#welcome'

  resources :users, :only => [:index, :new, :create, :show, :update] do
    collection do
      get :account
    end
  end

  resources :crosswords, :only => [:index, :new, :show, :create, :edit] do
    member do
      get :publish
    end
  end
  resources :clues, :only => [:index, :show]
  resources :words, :only => [:index, :show]
  resources :comments, :only => [:index, :create]
  resources :clue_instances, :only => [:index]
  resources :solutions, :only => [:index, :update] do
    member do
      post :get_incorrect
      post :check_correctness
    end
  end

  post '/login' => 'sessions#create'
  delete '/login' => 'sessions#destroy'

  get '/unauthorized' => 'pages#unauthorized'
  get '/account_required' => 'pages#account_required'
  get '/search' => 'pages#search'
  get '/live_search' => 'pages#live_search'
  get '/about' => 'pages#about'
  get '/contact' => 'pages#contact'

end
