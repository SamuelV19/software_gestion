class CreateSaleItems < ActiveRecord::Migration[7.1]
  def change
    create_table :sale_items do |t|
      t.references :sale, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :cantidad
      t.decimal :precio_unitario

      t.timestamps
    end
  end
end
