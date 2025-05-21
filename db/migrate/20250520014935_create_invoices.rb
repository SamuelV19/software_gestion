class CreateInvoices < ActiveRecord::Migration[7.1]
  def change
    create_table :invoices do |t|
      t.references :sale, null: false, foreign_key: true
      t.string :numero

      t.timestamps
    end
  end
end
