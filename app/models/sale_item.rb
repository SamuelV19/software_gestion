class SaleItem < ApplicationRecord
belongs_to :sale
belongs_to :product

before_validation :set_precio_unitario

  def set_precio_unitario
    self.precio_unitario ||= product.precio
  end
end
