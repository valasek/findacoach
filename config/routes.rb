Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    registrations: "users/registrations"
  }

  # public pages
  get "findacoach/index"
  get "findacoach/changelog"
  get "findacoach/admin"
  get "findacoach/contact"

  # app pages
  resources :clients do
    resources :sessions
  end

  # Standalone session routes for starting a session without a client
  resources :sessions, only: [ :new, :create ]
  get "session/start", to: "sessions#new", as: :start_session

  get "findacoach/dashboard"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "findacoach#index"
end
