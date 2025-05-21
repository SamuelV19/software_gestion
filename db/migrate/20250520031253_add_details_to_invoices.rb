class AddDetailsToInvoices < ActiveRecord::Migration[6.1]
  def change
    add_column :invoices, :nombre_cliente, :string
    add_column :invoices, :cedula, :string
    add_column :invoices, :direccion, :string
    add_column :invoices, :total, :decimal, precision: 10, scale: 2
    add_column :invoices, :fecha_emision, :datetime
  end
end
