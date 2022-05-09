class CategoriesController < ApplicationController
  # GET /categories
  def index
    render json: Category.all_categories, status: :ok
  end

  # GET /categories/:category_id
  def show
    @products = Category.select_products_by_category(params["id"])
    add_new_price
    render json: @products, status: :ok
  end

  private

  def add_new_price
    @products.map! do |product|
      product.update({ "new_price" => product["price"] * (100 - product["discount"]) / 100 })
      product.update({ "saving" => product["price"] - product["new_price"]})
    end
    @products = @products.each_slice(10).to_a
  end
end
