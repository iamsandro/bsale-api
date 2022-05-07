class CategoriesController < ApplicationController
  # GET /categories
  def index
    render json: Category.all_categories, status: :ok
  end

    # GET /categories/:category_id
  def show
    my_products = Category.select_products_by_category(params["id"])
    render json: my_products, status: :ok
  end
end