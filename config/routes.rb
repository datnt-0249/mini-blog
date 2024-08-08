Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    root 'static_pages#home'
    get "/sign-up", to: "users#new"
    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"
    get "/following-posts", to: "posts#following_posts"
    resources :users
    resources :posts do
      resources :likes, only: %i(create destroy)
    end
    resources :relationships, only: %i(create destroy)
  end

  namespace :api do
    namespace :v1 do
      post "/login", to: "sessions#create"
      get "/following-posts", to: "posts#following_posts"
      delete "/unfollow", to: "relationships#destroy"
      resources :relationships, only: %i(create)
      resources :posts, only: %i(create update)
    end
  end
end
