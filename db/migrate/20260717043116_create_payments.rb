class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :credit, null: false, foreign_key: true
      t.date :payment_date, null: false
      t.integer :payment_type, null: false, default: 0
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.decimal :principal_component, precision: 15, scale: 2, null: false
      t.decimal :interest_component, precision: 15, scale: 2, null: false
      t.decimal :insurance_component, precision: 15, scale: 2
      t.decimal :fees_component, precision: 15, scale: 2
      t.decimal :balance_after, precision: 15, scale: 2, null: false
      t.text :notes

      t.timestamps
    end
  end
end
