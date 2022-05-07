class Product
  def self.send_credentials
    credentials = Rails.configuration.database_configuration["default"]
    @client = Mysql2::Client.new(credentials)
  end

  def self.all_products
    send_credentials
    @client.query("SELECT * FROM product").to_a
  end

  def self.show_product(product_id)
    send_credentials
    @client.query("SELECT * FROM product WHERE id = #{product_id})").to_a
  end

  def self.sort_everything(sort_by, order)
    send_credentials
    @client.query("SELECT * FROM product ORDER BY #{sort_by} #{order}").to_a
  end

  def self.sort_by_category(category_id, sort_by, order)
    send_credentials
    @client.query("SELECT * FROM product WHERE category = #{category_id} ORDER BY #{sort_by} #{order}").to_a
  end

  def self.search(product_name)
    send_credentials
    @client.query("SELECT * FROM product WHERE product.name LIKE '%#{product_name}%'")
  end

  def self.search_with_sort(product_name, sort_by, order)
    send_credentials
    @client.query("SELECT * FROM product WHERE product.name LIKE '%#{product_name}%' ORDER BY #{sort_by} #{order}")
  end
end
