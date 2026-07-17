class InsurancePolicy < ApplicationRecord
  belongs_to :credit

  enum :policy_type, { vida_deudor: 0, todo_riesgo: 1, incendio_terremoto: 2, desempleo: 3, other: 4 }
  enum :premium_frequency, { monthly: 0, annual: 1, single: 2 }

  validates :insurer_name, presence: true
  validates :premium_amount, presence: true, numericality: { greater_than: 0 }
  validates :start_date, presence: true
end
