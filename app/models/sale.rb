class Sale < ApplicationRecord
  has_many :sale_items, dependent: :destroy
  has_one :invoice, dependent: :destroy

  attr_accessor :con_factura

  validates :nombre_cliente, presence: true, if: -> { con_factura }
  validates :cedula, presence: true, if: -> { con_factura }
  validates :direccion, presence: true, if: -> { con_factura }

  after_create :generar_factura, if: -> { con_factura }


  def generar_factura
    create_invoice!(
      numero: "FAC-#{id.to_s.rjust(6, '0')}",
      nombre_cliente: nombre_cliente,
      cedula: cedula,
      direccion: direccion,
      total: total,
      fecha_emision: Time.zone.now
    )
  end
end
