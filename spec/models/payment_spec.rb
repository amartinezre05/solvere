require "rails_helper"

RSpec.describe Payment, type: :model do
  it "is valid with the default factory" do
    expect(build(:payment)).to be_valid
  end

  it "requires a positive amount" do
    payment = build(:payment, amount: 0)
    expect(payment).not_to be_valid
  end

  it "requires a non-negative principal component" do
    payment = build(:payment, principal_component: -1)
    expect(payment).not_to be_valid
  end

  it "requires a non-negative balance_after" do
    payment = build(:payment, balance_after: -1)
    expect(payment).not_to be_valid
  end

  it "allows a blank insurance and fees component" do
    payment = build(:payment, insurance_component: nil, fees_component: nil)
    expect(payment).to be_valid
  end
end
