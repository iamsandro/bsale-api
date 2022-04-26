Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "categories#index"
  resources :categories, only: %I[index show]
  resources :products, only: %I[index show]

  get "products(/:id)/:by_sort/:order", to: "products#sort"
  get "search/:search", to: "categories#search"
end
