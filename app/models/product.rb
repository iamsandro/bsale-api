class Product
  # Por cada consulta se nos pide las credenciales, por lo cual se extrae las credenciales del database.yml
  def self.send_credentials
    credentials = Rails.configuration.database_configuration["default"]
    @client = Mysql2::Client.new(credentials)
  end

  # Consulta para obtener todos los productos "sin ordenar"
  def self.all_products
    send_credentials
    @client.query("SELECT * FROM product").to_a
  end

  # Esta consulta recibe un conjunto de ID's, y se realiza una consulta de todos ellos
  # Lo hice de esta manera para evitar hacer una consulta por cada ID
  def self.show_product(product_ids)
    send_credentials
    product_ids.map! { |id| "id = #{id}" }
    temp = product_ids.join(" OR ")
    @client.query("SELECT * FROM product WHERE #{temp}").to_a
  end

  # Esta consulta me entrega todos los productos "ordenados", ya sea por nombre, precio o descuento; ascendente o descendente
  def self.sort_everything(sort_by, order)
    send_credentials
    @client.query("SELECT * FROM product ORDER BY #{sort_by} #{order}").to_a
  end

  # Esta consulta va ordenar los productos de una categoría en específico
  # Lo hice de esta manera para evitar tener que filtrar manualmentepor categoría.
  def self.sort_by_category(category_id, sort_by, order)
    send_credentials
    @client.query("SELECT * FROM product WHERE category = #{category_id} ORDER BY #{sort_by} #{order}").to_a
  end

  # Esta consulta compara el nombre de cada producto, y devolverá las coincidencias.
  def self.search(product_name)
    send_credentials
    @client.query("SELECT * FROM product WHERE product.name LIKE '%#{product_name}%'").to_a
  end

  # Esta consulta devolverá todos los productos que coincidan con lo ingresado y ordenados
  def self.search_with_sort(product_name, sort_by, order)
    send_credentials
    @client.query("SELECT * FROM product WHERE product.name LIKE '%#{product_name}%' ORDER BY #{sort_by} #{order}").to_a
  end
end
