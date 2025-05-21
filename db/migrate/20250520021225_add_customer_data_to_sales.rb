class AddCustomerDataToSales < ActiveRecord::Migration[7.1]
  def change
    add_column :sales, :nombre_cliente, :string
    add_column :sales, :cedula, :string
    add_column :sales, :direccion, :string
  end
end
