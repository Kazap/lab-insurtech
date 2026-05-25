Rails.application.routes.draw do
  # Health check
  get "/up", to: ->(_) { [200, { "Content-Type" => "text/plain" }, ["ok"]] }

  namespace :api do
    namespace :v1 do
      resources :policyholders, only: [:show] do
        resources :claims, only: [:index], controller: "claims", as: :policyholder_claims
      end
      resources :policies, only: [:show] do
        resources :coverages, only: [:index]
      end
      resources :claims, only: [:create, :show]
    end
  end
end
