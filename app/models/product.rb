class Product < ApplicationRecord
  validates :nombre, presence: true, uniqueness: { case_sensitive: false }
  validates :precio, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  before_validation :normalize_nombre

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "descripcion", "id", "id_value", "nombre", "precio", "stock", "updated_at"]
  end

  private

  def normalize_nombre
    self.nombre = nombre.to_s.strip.gsub(/\s+/, ' ').downcase if nombre.present?
  end
end
