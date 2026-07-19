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

  describe "GET /credits/:id" do
    context "when not authenticated" do
      it "redirects to the sign in page" do
        credit = create(:credit)

        get credit_path(credit)

        expect(response).to redirect_to(new_session_path)
      end
    end

    context "when authenticated" do
      let(:user) { create(:user, password: "password") }

      before do
        post session_path, params: { email_address: user.email_address, password: "password" }
      end

      it "succeeds for a credit owned by the current user" do
        credit = create(:credit, user: user)

        get credit_path(credit)

        expect(response).to have_http_status(:ok)
      end

      it "returns not found for a credit owned by another user" do
        other_credit = create(:credit)

        get credit_path(other_credit)

        expect(response).to have_http_status(:not_found)
      end

      it "lists insurance policies for the credit" do
        credit = create(:credit, user: user)
        create(:insurance_policy, credit: credit, insurer_name: "Seguros Bolívar")

        get credit_path(credit)

        expect(response.body).to include("Seguros Bolívar")
      end

      it "marks already-made installments as paid and remaining ones as projected" do
        credit = create(:credit, user: user, principal_amount: 20_000_000, term_months: 12)
        create(:payment, credit: credit, payment_type: :installment, payment_date: Date.current, principal_component: 500_000, balance_after: 19_500_000)

        get credit_path(credit)

        expect(response.body.scan("Pagada").size).to eq(1)
        expect(response.body.scan("Proyectada").size).to eq(11)
      end

      it "lists the full payment history, including extra principal payments" do
        credit = create(:credit, user: user)
        create(:payment, credit: credit, payment_type: :extra_principal, amount: 1_000_000, principal_component: 1_000_000, interest_component: 0, balance_after: 19_000_000)

        get credit_path(credit)

        expect(response.body).to include("Extra principal")
      end
    end
  end

  describe "GET /credits/new" do
    it "redirects to the sign in page when not authenticated" do
      get new_credit_path

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "POST /credits" do
    let(:user) { create(:user, password: "password") }
    let(:credit_type) { create(:credit_type) }
    let(:valid_params) do
      {
        credit_type_id: credit_type.id,
        lender_name: "Bancolombia",
        principal_amount: 20_000_000,
        currency: "cop",
        term_months: 36,
        interest_rate_type: "fixed",
        interest_rate_ea: 18.5,
        amortization_system: "cuota_fija",
        disbursement_date: Date.current,
        first_payment_date: Date.current + 1.month,
        payment_day: 5,
        status: "active"
      }
    end

    before do
      post session_path, params: { email_address: user.email_address, password: "password" }
    end

    it "creates a credit owned by the current user and redirects to it" do
      expect {
        post credits_path, params: { credit: valid_params }
      }.to change { user.credits.count }.by(1)

      expect(response).to redirect_to(credit_path(user.credits.last))
    end

    it "re-renders the form with errors when the params are invalid" do
      post credits_path, params: { credit: valid_params.merge(lender_name: "") }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("impidieron guardar")
    end
  end

  describe "GET /credits/:id/edit" do
    let(:user) { create(:user, password: "password") }

    before do
      post session_path, params: { email_address: user.email_address, password: "password" }
    end

    it "returns not found for a credit owned by another user" do
      other_credit = create(:credit)

      get edit_credit_path(other_credit)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /credits/:id" do
    let(:user) { create(:user, password: "password") }

    before do
      post session_path, params: { email_address: user.email_address, password: "password" }
    end

    it "updates a credit owned by the current user" do
      credit = create(:credit, user: user, lender_name: "Bancolombia")

      patch credit_path(credit), params: { credit: { lender_name: "Davivienda" } }

      expect(response).to redirect_to(credit_path(credit))
      expect(credit.reload.lender_name).to eq("Davivienda")
    end

    it "does not update a credit owned by another user" do
      other_credit = create(:credit, lender_name: "Bancolombia")

      patch credit_path(other_credit), params: { credit: { lender_name: "Davivienda" } }

      expect(response).to have_http_status(:not_found)
      expect(other_credit.reload.lender_name).to eq("Bancolombia")
    end
  end

  describe "GET /credits/estimate" do
    let(:user) { create(:user, password: "password") }

    before do
      post session_path, params: { email_address: user.email_address, password: "password" }
    end

    it "returns the estimated cuota fija installment for the given inputs" do
      get estimate_credits_path, params: {
        principal_amount: 20_000_000, term_months: 12, interest_rate_ea: 18.5, amortization_system: "cuota_fija"
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("$")
      expect(response.body).not_to include("—")
    end

    it "returns a placeholder when the inputs are incomplete" do
      get estimate_credits_path, params: { principal_amount: "", term_months: "", interest_rate_ea: "" }

      expect(response.body.strip).to eq("—")
    end
  end
end
