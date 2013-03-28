Xword::Application.routes.draw do
  root :to => 'pages#home'

  resources :users, :only => [:index, :new, :create, :show, :update] do
    collection do
      get :account
    end
  end

  resources :crosswords, :only => [:index, :new, :show, :create, :edit]
  resources :clues, :only => [:index, :show]
  resources :words, :only => [:index, :show]
  resources :comments, :only => [:index]
  resources :clue_instances, :only => [:index]
  resources :solutions, :only => [:index]

  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  delete '/login' => 'sessions#destroy'

  get '/unauthorized' => 'pages#unauthorized'
  get '/account_required' => 'pages#account_required'
  get '/search' => 'pages#search'

end
