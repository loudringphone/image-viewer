Rails.application.routes.draw do
  resources :images

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "images#index"
  get '/images' => "images#index"
  get '/images/:id' => "images#show", constraints: { id: /\d+/ }
  get '/images_json' => "images#images_json"
  get '/images/:id/user_count', to: 'images#user_count'
end