Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # HTMX endpoints
  get "plants/table_rows", to: "plants#table_rows", as: "plants_table_rows", defaults: { format: :html }

  # Mount ActionCable server
  mount ActionCable.server => '/cable'

  # API routes
  namespace :api do
    resources :readings, only: [:create]
  end

  # Plant dashboard and management
  resources :plants do
    resources :moisture_readings, only: [:create]
  end

  # Add poll_updates route
  get 'poll_updates', to: 'dashboard#poll_updates', defaults: { format: :json }

  # Defines the root path route ("/")
  root "dashboard#index"
end
