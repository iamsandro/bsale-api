class Category < ApplicationRecord
  # change name products to product
  set_table_name "product"

  # associations
  has_many :category, dependent: :destroy
end
