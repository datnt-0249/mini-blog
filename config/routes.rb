Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    root 'static_pages#home'
    get "/sign-up", to: "users#new"
    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"
    resources :users
    resources :posts do
      resources :likes, only: %i(create destroy)
    end
    resources :relationships, only: %i(create destroy)
  end
end
