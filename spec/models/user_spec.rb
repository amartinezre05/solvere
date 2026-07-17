require "rails_helper"

RSpec.describe User, type: :model do
  it "is valid with an email address and password" do
    expect(build(:user)).to be_valid
  end

  it "requires a password" do
    user = build(:user, password: nil)
    expect(user).not_to be_valid
  end

  it "requires a unique email address" do
    create(:user, email_address: "duplicate@example.com")
    duplicate = build(:user, email_address: "duplicate@example.com")
    expect(duplicate).not_to be_valid
  end

  it "normalizes the email address to lowercase and strips whitespace" do
    user = create(:user, email_address: "  Test@Example.com  ")
    expect(user.email_address).to eq("test@example.com")
  end

  it "destroys associated sessions when destroyed" do
    user = create(:user)
    session = user.sessions.create!(user_agent: "RSpec", ip_address: "127.0.0.1")

    expect { user.destroy }.to change { Session.exists?(session.id) }.from(true).to(false)
  end
end
