class CreateCredits < ActiveRecord::Migration[8.1]
  def change
    create_table :credits do |t|
      t.references :user, null: false, foreign_key: true
      t.references :credit_type, null: false, foreign_key: true

      t.string :lender_name, null: false
      t.decimal :principal_amount, precision: 15, scale: 2, null: false
      t.integer :currency, null: false, default: 0
      t.decimal :uvr_value_at_disbursement, precision: 12, scale: 4
      t.integer :term_months, null: false

      t.integer :interest_rate_type, null: false, default: 0
      t.decimal :interest_rate_ea, precision: 8, scale: 4, null: false
      t.integer :variable_rate_index, null: false, default: 0
      t.decimal :variable_rate_spread, precision: 8, scale: 4

      t.integer :amortization_system, null: false, default: 0

      t.decimal :down_payment, precision: 15, scale: 2
      t.date :disbursement_date, null: false
      t.date :first_payment_date, null: false
      t.integer :payment_day, null: false
      t.integer :grace_period_months, null: false, default: 0

      t.decimal :notary_fees, precision: 15, scale: 2
      t.decimal :registration_fees, precision: 15, scale: 2
      t.decimal :appraisal_fee, precision: 15, scale: 2
      t.decimal :origination_fee, precision: 15, scale: 2
      t.decimal :management_fee, precision: 15, scale: 2
      t.boolean :gmf_applicable, null: false, default: false

      t.integer :collateral_type, null: false, default: 0
      t.string :collateral_description
      t.decimal :subsidy_amount, precision: 15, scale: 2

      t.integer :status, null: false, default: 0
      t.text :notes

      t.timestamps
    end
  end
end
