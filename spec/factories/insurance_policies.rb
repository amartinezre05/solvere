FactoryBot.define do
  factory :insurance_policy do
    credit
    policy_type { :vida_deudor }
    insurer_name { "Seguros Bolívar" }
    premium_amount { 25_000 }
    premium_frequency { :monthly }
    start_date { Date.current }
  end
end
