require "rails_helper"

RSpec.describe InsurancePolicy, type: :model do
  it "is valid with the default factory" do
    expect(build(:insurance_policy)).to be_valid
  end

  it "requires a positive premium amount" do
    policy = build(:insurance_policy, premium_amount: 0)
    expect(policy).not_to be_valid
  end

  it "requires an insurer name" do
    policy = build(:insurance_policy, insurer_name: nil)
    expect(policy).not_to be_valid
  end
end
