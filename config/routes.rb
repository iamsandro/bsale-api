Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "products#index"
  # resources :categories, only: %I[index show]
  resources :products, only: %I[index show]

  get "products(/category/:id)/:by_sort/:order", to: "products#sort"
  get "search/:search(/:by_sort/:order)", to: "products#search"
  get "categories", to: "products#categories_of_products"
  get "categories/:category_id", to: "products#show_products_by_category"
  get "clasification_types", to: "products#clasification_types"
end
