Xword::Application.routes.draw do
  root :to => 'pages#home'

  resources :users, :only => [:index, :new, :show]
  resources :crosswords, :only => [:index, :new, :show]
end
