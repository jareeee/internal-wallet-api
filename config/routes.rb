Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  post "/v1/auth", to: "v1/sessions#create"
  delete "/v1/auth", to: "v1/sessions#destroy"

  namespace :v1 do
    resources :wallets, only: [ :show ]
    get "/wallets/by_owner", to: "wallets#by_owner"
  end
end
