class Product < ApplicationRecord
  # change name products to product
  set_table_name "product"

  # associations
  belongs_to :category
end
