require "rails_helper"

RSpec.describe UvrValue, type: :model do
  it "is valid with a date and a positive value" do
    expect(build(:uvr_value)).to be_valid
  end

  it "requires a unique date" do
    create(:uvr_value, date: Date.new(2026, 1, 1))
    duplicate = build(:uvr_value, date: Date.new(2026, 1, 1))
    expect(duplicate).not_to be_valid
  end

  it "requires a positive value" do
    uvr_value = build(:uvr_value, value: 0)
    expect(uvr_value).not_to be_valid
  end
end
