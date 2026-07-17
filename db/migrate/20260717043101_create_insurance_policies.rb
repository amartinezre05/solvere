class CreateInsurancePolicies < ActiveRecord::Migration[8.1]
  def change
    create_table :insurance_policies do |t|
      t.references :credit, null: false, foreign_key: true
      t.integer :policy_type, null: false
      t.string :insurer_name, null: false
      t.decimal :premium_amount, precision: 15, scale: 2, null: false
      t.integer :premium_frequency, null: false, default: 0
      t.date :start_date, null: false
      t.date :end_date

      t.timestamps
    end
  end
end
