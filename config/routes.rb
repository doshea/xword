Xword::Application.routes.draw do
  root :to => 'pages#home'

  resources :users, :only => [:new, :index]
end
