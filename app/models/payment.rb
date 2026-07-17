class Payment < ApplicationRecord
  belongs_to :credit

  enum :payment_type, { installment: 0, extra_principal: 1, full_settlement: 2 }

  validates :payment_date, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :principal_component, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :interest_component, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :insurance_component, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :fees_component, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :balance_after, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
