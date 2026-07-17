class Credit < ApplicationRecord
  belongs_to :user
  belongs_to :credit_type
  has_many :insurance_policies, dependent: :destroy
  has_many :payments, dependent: :destroy

  enum :currency, { cop: 0, uvr: 1 }
  enum :interest_rate_type, { fixed: 0, variable: 1 }
  enum :variable_rate_index, { none: 0, ibr: 1, uvr: 2 }, prefix: true
  enum :amortization_system, { cuota_fija: 0, abono_constante: 1 }
  enum :collateral_type, { ninguna: 0, hipoteca: 1, prenda: 2 }
  enum :status, { active: 0, paid_off: 1, defaulted: 2, written_off: 3 }

  validates :lender_name, presence: true
  validates :principal_amount, presence: true, numericality: { greater_than: 0 }
  validates :term_months, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :interest_rate_ea, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :variable_rate_spread, presence: true, numericality: { greater_than_or_equal_to: 0 }, if: :variable?
  validates :disbursement_date, presence: true
  validates :first_payment_date, presence: true
  validates :payment_day, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 31 }
  validates :grace_period_months, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :uvr_value_at_disbursement, presence: true, numericality: { greater_than: 0 }, if: :uvr?
end
