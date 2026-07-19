require "rails_helper"

RSpec.describe "Credits", type: :request do
  describe "GET /credits" do
    context "when not authenticated" do
      it "redirects to the sign in page" do
        get credits_path

        expect(response).to redirect_to(new_session_path)
      end
    end

    context "when authenticated" do
      let(:user) { create(:user, password: "password") }

      before do
        post session_path, params: { email_address: user.email_address, password: "password" }
      end

      it "succeeds" do
        get credits_path

        expect(response).to have_http_status(:ok)
      end

      it "lists only the current user's credits" do
        credit_type = create(:credit_type)
        my_credit = create(:credit, user: user, credit_type: credit_type, lender_name: "Bancolombia")
        other_credit = create(:credit, credit_type: credit_type, lender_name: "Davivienda")

        get credits_path

        expect(response.body).to include("Bancolombia")
        expect(response.body).not_to include("Davivienda")
      end

      it "shows the current balance net of any payments made" do
        credit = create(:credit, user: user, principal_amount: 20_000_000)
        create(:payment, credit: credit, principal_component: 500_000)

        get credits_path

        expect(response.body).to include("19.500.000")
      end

      it "shows an empty state when the user has no credits" do
        get credits_path

        expect(response.body).to include("Todavía no tienes créditos registrados")
      end
    end
  end
end
