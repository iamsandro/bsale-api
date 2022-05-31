class Category
  # Por cada consulta se nos pide las credenciales, por lo cual se extrae las credenciales del database.yml
  def self.send_credentials
    credentials = Rails.configuration.database_configuration["default"]
    @client = Mysql2::Client.new(credentials)
  end

  # Esta consulta extrae todas la categorías.
  def self.all_categories
    send_credentials
    @client.query("SELECT * FROM category").to_a
  end

  # Esta consulta devuelve todos los producto de una categoría en específico.
  def self.select_products_by_category(category_id)
    send_credentials
    @client.query("SELECT * FROM product WHERE category = #{category_id}").to_a
  end
end
