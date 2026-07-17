# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_17_043116) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "credit_types", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.boolean "requires_collateral", default: false, null: false
    t.string "slug", null: false
    t.boolean "tax_deductible", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_credit_types_on_name", unique: true
    t.index ["slug"], name: "index_credit_types_on_slug", unique: true
  end

  create_table "credits", force: :cascade do |t|
    t.integer "amortization_system", default: 0, null: false
    t.decimal "appraisal_fee", precision: 15, scale: 2
    t.string "collateral_description"
    t.integer "collateral_type", default: 0, null: false
    t.datetime "created_at", null: false
    t.bigint "credit_type_id", null: false
    t.integer "currency", default: 0, null: false
    t.date "disbursement_date", null: false
    t.decimal "down_payment", precision: 15, scale: 2
    t.date "first_payment_date", null: false
    t.boolean "gmf_applicable", default: false, null: false
    t.integer "grace_period_months", default: 0, null: false
    t.decimal "interest_rate_ea", precision: 8, scale: 4, null: false
    t.integer "interest_rate_type", default: 0, null: false
    t.string "lender_name", null: false
    t.decimal "management_fee", precision: 15, scale: 2
    t.decimal "notary_fees", precision: 15, scale: 2
    t.text "notes"
    t.decimal "origination_fee", precision: 15, scale: 2
    t.integer "payment_day", null: false
    t.decimal "principal_amount", precision: 15, scale: 2, null: false
    t.decimal "registration_fees", precision: 15, scale: 2
    t.integer "status", default: 0, null: false
    t.decimal "subsidy_amount", precision: 15, scale: 2
    t.integer "term_months", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.decimal "uvr_value_at_disbursement", precision: 12, scale: 4
    t.integer "variable_rate_index", default: 0, null: false
    t.decimal "variable_rate_spread", precision: 8, scale: 4
    t.index ["credit_type_id"], name: "index_credits_on_credit_type_id"
    t.index ["user_id"], name: "index_credits_on_user_id"
  end

  create_table "insurance_policies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "credit_id", null: false
    t.date "end_date"
    t.string "insurer_name", null: false
    t.integer "policy_type", null: false
    t.decimal "premium_amount", precision: 15, scale: 2, null: false
    t.integer "premium_frequency", default: 0, null: false
    t.date "start_date", null: false
    t.datetime "updated_at", null: false
    t.index ["credit_id"], name: "index_insurance_policies_on_credit_id"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount", precision: 15, scale: 2, null: false
    t.decimal "balance_after", precision: 15, scale: 2, null: false
    t.datetime "created_at", null: false
    t.bigint "credit_id", null: false
    t.decimal "fees_component", precision: 15, scale: 2
    t.decimal "insurance_component", precision: 15, scale: 2
    t.decimal "interest_component", precision: 15, scale: 2, null: false
    t.text "notes"
    t.date "payment_date", null: false
    t.integer "payment_type", default: 0, null: false
    t.decimal "principal_component", precision: 15, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["credit_id"], name: "index_payments_on_credit_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  create_table "uvr_values", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.datetime "updated_at", null: false
    t.decimal "value", precision: 12, scale: 4, null: false
    t.index ["date"], name: "index_uvr_values_on_date", unique: true
  end

  add_foreign_key "credits", "credit_types"
  add_foreign_key "credits", "users"
  add_foreign_key "insurance_policies", "credits"
  add_foreign_key "payments", "credits"
  add_foreign_key "sessions", "users"
end
