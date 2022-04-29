require "rails_helper"

describe "Products", type: :request do
  describe "index products" do
    it "respond with http success status code" do
      get "/products"
      # json = JSON.parse(response.body)
      expect(response.content_type).to eq("application/json; charset=utf-8")
      expect(response).to have_http_status(:ok)
    end
  end

  describe "show products" do
    it "respond with http not found status code" do
      get "/products/xxx"
      expect(response.content_type).to eq("application/json; charset=utf-8")
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "order all products by name, price, discount" do
    it "respond with http success status code" do
      get "/products/name/asc"
      expect(response).to have_http_status(:ok)
      get "/products/price/desc"
      expect(response).to have_http_status(:ok)
      get "/products/discount/asc"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "order products by category by name, price, discount" do
    it "respond with http success status code" do
      get "/products/category/4/name/asc"
      expect(response).to have_http_status(:ok)
      get "/products/category/4/price/desc"
      expect(response).to have_http_status(:ok)
      get "/products/category/4/discount/asc"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "order the products the user is looking for by name, price, discount" do
    it "respond with http success status code" do
      get "/search/papas/name/asc"
      expect(response).to have_http_status(:ok)
      get "/search/papas/price/desc"
      expect(response).to have_http_status(:ok)
      get "/search/papas/price/desc"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "show all type of products of clasification" do
    it "respon with un array of all type clasification" do
      types = ["name A-Z", "name Z-A", "price asc", "price desc", "discount asc", "discount desc"]
      get "/clasification_types"
      obteined_array = JSON.parse(response.body)
      pp obteined_array
      expect(obteined_array).to eq(types)
    end
  end

  describe "show products with same category" do
    it "respond with array of objects with same category" do
      get "/categories/7"
      obteined_array = JSON.parse(response.body)
      expect(obteined_array[0]["category"]).to eq(7)
    end
  end
end
