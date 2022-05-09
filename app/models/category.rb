class Category
  def self.send_credentials
    credentials = Rails.configuration.database_configuration["default"]
    @client = Mysql2::Client.new(credentials)
  end

  def self.all_categories
    send_credentials
    @client.query("SELECT * FROM category").to_a
  end

  def self.select_products_by_category(category_id)
    send_credentials
    @client.query("SELECT * FROM product WHERE category = #{category_id}").to_a
  end
end
