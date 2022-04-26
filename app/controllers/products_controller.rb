class ProductsController < ApplicationController
  before_action :set_product, only: %I[show index sort search]

  # GET /category or /category.json
  def index
    render json: @products
  end

  # GET /category/:sort_by/:order || GET /category/:category_id/:sort_by/:order
  def sort
    products = params["id"].nil? ? @products : @products.select { |x| x["category"] == params["id"].to_i }
    my_products = products.sort_by { |product| product[params["by_sort"]] }

    render json: params["order"] == "asc" ? my_products : my_products.reverse
  end

  # GET /search/:name_product
  def search
    product_searched = @products.select { |x| x["name"].include?(params["search"].upcase) }
    render json: product_searched
  end

  private

  def set_product
    client = Mysql2::Client.new(host: ENV["RDS_HOSTNAME"],
                                username: ENV["RDS_DB_NAME"],
                                password: ENV["RDS_PASSWORD"],
                                database: ENV["RDS_DB_NAME"])
    @products = client.query("SELECT * FROM product").to_a
  end

  # Only allow a list of trusted parameters through.
  def Product_params
    params.require(:product).permit(:name, :url_image, :price, :discount, :category)
  end
end
