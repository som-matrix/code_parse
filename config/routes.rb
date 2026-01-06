CodeParse::Engine.routes.draw do
  namespace :api do
    resources :models, only: [ :index ]
    resources :schema, only: [ :index ]
    resources :controllers, only: [ :index ]
  end
end
