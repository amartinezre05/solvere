FactoryBot.define do
  factory :payment do
    credit
    payment_date { Date.current }
    payment_type { :installment }
    amount { 722_654 }
    principal_component { 415_487 }
    interest_component { 307_167 }
    balance_after { 19_584_513 }
  end
end
