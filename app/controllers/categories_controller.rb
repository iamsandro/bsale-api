class CategoriesController < ApplicationController
  before_action :set_category,
                only: %I[index show]

  # GET /category or /category.json
  def index; end

  # GET /category/:category_id
  def show; end

  private

  def set_category
    client = Mysql2::Client.new(host: ENV.fetch("RDS_HOSTNAME", nil),
                                username: ENV.fetch("RDS_DB_NAME", nil),
                                password: ENV.fetch("RDS_PASSWORD", nil),
                                database: ENV.fetch("RDS_DB_NAME", nil))
    @categories = client.query("SELECT * FROM category").to_a
    @products = client.query("SELECT * FROM product").to_a
  end

  # Only allow a list of trusted parameters through.
  def category_params
    params.require(:category).permit(:name)
  end
end
