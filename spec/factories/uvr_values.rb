FactoryBot.define do
  factory :uvr_value do
    sequence(:date) { |n| Date.current - n.days }
    value { 355.29 }
  end
end
