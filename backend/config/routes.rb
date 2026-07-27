Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Routes mirror the endpoint list at the bottom of docs/02-data-model.md 1:1 — see
  # docs/18-backend-build-plan.md for the controller grouping this follows.
  namespace :api do
    resources :cities, only: [:index]
    resources :users, only: [:show, :update]
    get "users/:id/followed-tags", to: "users#followed_tags"

    # Tag names aren't UUIDs (e.g. "Group Ride") — allow any non-slash string.
    get "tags/:name", to: "tags#show", constraints: { name: /[^\/]+/ }
    post "tags/:name/follow", to: "tags#follow", constraints: { name: /[^\/]+/ }
    delete "tags/:name/follow", to: "tags#unfollow", constraints: { name: /[^\/]+/ }

    get "feed", to: "posts#feed"
    get "listings", to: "listings#index"

    resources :posts, only: [:show, :create, :update, :destroy] do
      resources :comments, only: [:index, :create], controller: "posts/comments"

      member do
        post :like
        delete :like, action: :unlike
      end
    end

    resources :groups, only: [:index, :show, :create, :update, :destroy] do
      member do
        post :join
        delete :join, action: :leave
        post :block
      end
    end

    resources :reports, only: [:create]

    resources :notifications, only: [:index] do
      member do
        post :read
      end
    end

    resources :uploads, only: [:create]

    get "chats", to: "chats#index"
    get "chats/:user_id/messages", to: "chats#messages"
    post "chats/:user_id/messages", to: "chats#create_message"
    post "chats/:user_id/read", to: "chats#read"
  end
end
