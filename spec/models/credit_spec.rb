require "rails_helper"

RSpec.describe Credit, type: :model do
  it "is valid with the default factory" do
    expect(build(:credit)).to be_valid
  end

  it "requires a positive principal amount" do
    credit = build(:credit, principal_amount: 0)
    expect(credit).not_to be_valid
  end

  it "requires a positive term in months" do
    credit = build(:credit, term_months: 0)
    expect(credit).not_to be_valid
  end

  it "requires a variable rate spread when the rate type is variable" do
    credit = build(:credit, :variable, variable_rate_spread: nil)
    expect(credit).not_to be_valid
  end

  it "does not require a variable rate spread when the rate type is fixed" do
    credit = build(:credit, interest_rate_type: :fixed, variable_rate_spread: nil)
    expect(credit).to be_valid
  end

  it "requires a UVR value at disbursement when the currency is UVR" do
    credit = build(:credit, currency: :uvr, uvr_value_at_disbursement: nil)
    expect(credit).not_to be_valid
  end

  it "does not require a UVR value at disbursement when the currency is COP" do
    credit = build(:credit, currency: :cop, uvr_value_at_disbursement: nil)
    expect(credit).to be_valid
  end

  it "destroys associated payments and insurance policies when destroyed" do
    credit = create(:credit)
    payment = create(:payment, credit: credit)
    policy = create(:insurance_policy, credit: credit)

    credit.destroy

    expect(Payment.exists?(payment.id)).to be false
    expect(InsurancePolicy.exists?(policy.id)).to be false
  end
end
