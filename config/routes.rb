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
    get "/wallets/:id", to: "wallets#show"
    get "/wallet/by_owner", to: "wallets#by_owner"

    # Transactions
    post "/wallet/deposits", to: "deposits#create"
    post "/wallet/withdrawals", to: "withdrawals#create"
    post "/wallet/transfers", to: "transfers#create"

    # External stock prices
    get "/stock_prices", to: "stock_prices#index"
  end
end
