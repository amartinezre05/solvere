require "rails_helper"

RSpec.describe CreditType, type: :model do
  it "is valid with a name and slug" do
    expect(build(:credit_type)).to be_valid
  end

  it "requires a unique name" do
    create(:credit_type, name: "Vivienda VIS")
    duplicate = build(:credit_type, name: "Vivienda VIS")
    expect(duplicate).not_to be_valid
  end

  it "requires a unique slug" do
    create(:credit_type, slug: "vivienda-vis")
    duplicate = build(:credit_type, slug: "vivienda-vis")
    expect(duplicate).not_to be_valid
  end

  it "prevents destruction while credits reference it" do
    credit_type = create(:credit_type)
    create(:credit, credit_type: credit_type)

    expect { credit_type.destroy }.not_to change(CreditType, :count)
  end
end
