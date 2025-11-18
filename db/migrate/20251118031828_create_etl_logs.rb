class CreateEtlLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :etl_logs do |t|
      t.references :product, null: false, foreign_key: true
      t.string :cambio
      t.string :valor_anterior
      t.string :valor_nuevo

      t.timestamps
    end
  end
end
