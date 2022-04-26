class CategoriesController < ApplicationController
  before_action :set_category,
                only: %I[index show]

  # GET /category or /category.json
  def index
    render json: @categories
  end

  # GET /category/:category_id
  def show
    my_products = @products.select { |product| product["category"].eql? params["id"].to_i }
    render json: my_products
  end

  private
  
  def set_category
    client = Mysql2::Client.new(host: ENV["RDS_HOSTNAME"],
                                username: ENV["RDS_DB_NAME"],
                                password: ENV["RDS_PASSWORD"],
                                database: ENV["RDS_DB_NAME"])
    @categories = client.query("SELECT * FROM category").to_a
    @products = client.query("SELECT * FROM product").to_a
  end

  # Only allow a list of trusted parameters through.
  def category_params
    params.require(:category).permit(:name)
  end
end
