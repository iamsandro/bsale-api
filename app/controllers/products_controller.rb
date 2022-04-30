class ProductsController < ApplicationController
  before_action :set_product,
                only: %I[index show sort search show_products_by_category categories_of_products]

  # GET /products or /products.json
  def index
    render json: @products, status: :ok
  end

  # GET /products/:id
  def show
    product = @products.find { |item| item["id"].eql?(params["id"].to_i) }
    if product.nil?
      render json: { error: "product doesn't exist or it was deleted" }, status: :not_found
    else
      render json: product, status: :ok
    end
  end

  # GET /products/:sort_by/:order || GET /products/:product_id/:sort_by/:order
  def sort
    products = @products
    unless params["id"].nil?
      products = @products.select { |product| product["category"].eql?(params["id"].to_i) }
    end
    ordered_products = products.sort_by { |product| product[params["by_sort"]] }
    is_asc = params["order"].eql?("asc") || params["order"].eql?("A-Z")

    if ordered_products.empty?
      render json: { error: "Category ID wrong or doesn't has products" }, status: :bad_request
    else
      render json: is_asc ? ordered_products : ordered_products.reverse, status: :ok
    end
  end

  # GET /categories
  def categories_of_products
    render json: @categories
  end

  # GET /categories/:category_id
  def show_products_by_category
    my_products = @products.select do |product|
      product["category"] == params["category_id"].to_i
    end
    render json: my_products, status: :ok
  end

  # GET /clasificacion_types
  def clasification_types
    types = ["name A-Z", "name Z-A", "price asc", "price desc", "discount asc", "discount desc"]
    render json: types
  end

  # GET /search/:name_product(/:by_sort/:order)
  def search
    product_searched = @products.select do |product|
      product["name"].upcase.include?(params["search"].upcase)
    end
    product_searched.sort_by! { |product| product[params["by_sort"]] } if params["by_sort"]
    product_searched.reverse! if params["order"].eql?("desc")

    render json: product_searched, status: :ok
  end

  private

  def set_product
    credentials = Rails.configuration.database_configuration["default"]
    client = Mysql2::Client.new(credentials)
    @products = client.query("SELECT * FROM product").to_a
    @categories = client.query("SELECT * FROM category").to_a
  end
end
