FactoryBot.define do
  factory :credit_type do
    sequence(:name) { |n| "Libre inversión #{n}" }
    sequence(:slug) { |n| "libre-inversion-#{n}" }
    requires_collateral { false }
    tax_deductible { false }
    description { "Crédito sin destinación específica" }
  end
end
