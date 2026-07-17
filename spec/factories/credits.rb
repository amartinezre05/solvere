FactoryBot.define do
  factory :credit do
    user
    credit_type
    lender_name { "Bancolombia" }
    principal_amount { 20_000_000 }
    currency { :cop }
    term_months { 36 }
    interest_rate_type { :fixed }
    interest_rate_ea { 18.5 }
    amortization_system { :cuota_fija }
    disbursement_date { Date.current }
    first_payment_date { Date.current + 1.month }
    payment_day { 5 }
    grace_period_months { 0 }
    gmf_applicable { false }
    collateral_type { :ninguna }
    status { :active }

    trait :vivienda_uvr do
      currency { :uvr }
      uvr_value_at_disbursement { 355.29 }
      collateral_type { :hipoteca }
      term_months { 180 }
    end

    trait :variable do
      interest_rate_type { :variable }
      variable_rate_index { :ibr }
      variable_rate_spread { 4.5 }
    end
  end
end
