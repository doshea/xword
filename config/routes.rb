Xword::Application.routes.draw do
  root :to => 'pages#home'

  resources :users, :only => [:index, :new, :create, :show] do
    collection do
      get 'account'
    end
  end

  resources :crosswords, :only => [:index, :new, :show]
  resources :clues, :only => [:index, :show]
  resources :words, :only => [:index, :show]

  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  delete '/login' => 'sessions#destroy'

end
