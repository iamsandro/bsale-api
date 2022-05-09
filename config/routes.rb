Rails.application.routes.draw do
  resources :products, only: %I[index show]
  resources :categories, only: %I[index show]

  get "products(/category/:category_id)/:by_sort/:order", to: "products#sort"
  get "search/:search(/:by_sort/:order)", to: "products#search"
  get "clasification_types", to: "products#clasification_types"
  get "array/:array_id", to: "products#search_products"
end
