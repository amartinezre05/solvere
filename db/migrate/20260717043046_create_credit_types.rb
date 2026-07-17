class CreateCreditTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :credit_types do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.boolean :requires_collateral, null: false, default: false
      t.boolean :tax_deductible, null: false, default: false
      t.text :description

      t.timestamps
    end
    add_index :credit_types, :name, unique: true
    add_index :credit_types, :slug, unique: true
  end
end
