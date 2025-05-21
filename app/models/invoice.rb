class Invoice < ApplicationRecord
  belongs_to :sale

  validates :numero, presence: true
  validates :nombre_cliente, presence: true
  validates :cedula, presence: true
  validates :direccion, presence: true
  validates :total, presence: true
  validates :fecha_emision, presence: true

  before_create :set_fecha_emision

  private

  def set_fecha_emision
    self.fecha_emision ||= Time.zone.now
  end
end
