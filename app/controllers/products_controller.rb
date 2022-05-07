class ProductsController < ApplicationController

  # GET /products or /products.json
  def index
    render json: Product.all_products, status: :ok
  end

  # GET /products/:id
  def show
    product = Product.show_product(params["id"])
    if product.nil?
      render json: { error: "product doesn't exist or it was deleted" }, status: :not_found
    else
      render json: product, status: :ok
    end
  end

  # GET /products/:sort_by/:order || GET /products/:product_id/:sort_by/:order
  def sort
    by_sort = params["by_sort"]
    order = params["order"].eql?("A-Z") || params["order"].eql?("asc") ? "ASC" : "DESC"
    category_id = params["category_id"]

    products_sorted = if category_id.nil?
                        Product.sort_everything(by_sort, order)
                      else
                        Product.sort_by_category(category_id, by_sort, order)
                      end

    if products_sorted.empty?
      render json: { error: "Category ID wrong or doesn't has products" }, status: :bad_request
    else
      render json: products_sorted, status: :ok
    end
  end

  # GET /clasificacion_types
  def clasification_types
    types = ["name A-Z", "name Z-A", "price asc", "price desc", "discount asc", "discount desc"]
    render json: types
  end

  # GET /search/:name_product(/:by_sort/:order)
  def search
    product_name = params["search"]
    by_sort = params["by_sort"]
    order = params["order"]&.eql?("A-Z") || params["order"].eql?("asc") ? "ASC" : "DESC"
    products_found = Product.search(product_name) if by_sort.nil?
    products_found = Product.search_with_sort(product_name, by_sort, order) unless by_sort.nil?

    render json: products_found, status: :ok
  end

  private

  def product_params
    # params.require(:product).permit "category_id"
    params.require(:category_id)
  end
end
