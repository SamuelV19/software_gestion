class AddAnuladaToSales < ActiveRecord::Migration[7.0]
  def change
    add_column :sales, :anulada, :boolean, default: false
  end
end
