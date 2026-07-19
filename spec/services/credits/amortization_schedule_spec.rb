require "rails_helper"

RSpec.describe Credits::AmortizationSchedule do
  describe "#current_balance" do
    it "equals principal_amount when no payments exist" do
      credit = create(:credit, principal_amount: 20_000_000)

      expect(described_class.new(credit).current_balance).to eq(20_000_000)
    end

    it "subtracts the principal_component of every payment" do
      credit = create(:credit, principal_amount: 20_000_000)
      create(:payment, credit: credit, principal_component: 400_000)
      create(:payment, credit: credit, principal_component: 450_000)

      expect(described_class.new(credit).current_balance).to eq(19_150_000)
    end
  end

  describe "#remaining_term_months" do
    it "equals term_months minus the number of installment payments made" do
      credit = create(:credit, term_months: 36)
      create_list(:payment, 2, credit: credit, payment_type: :installment)
      create(:payment, credit: credit, payment_type: :extra_principal)

      expect(described_class.new(credit).remaining_term_months).to eq(34)
    end

    it "never goes below zero" do
      credit = create(:credit, term_months: 1)
      create_list(:payment, 2, credit: credit, payment_type: :installment)

      expect(described_class.new(credit).remaining_term_months).to eq(0)
    end
  end

  describe "#upcoming_installments" do
    context "with amortization_system cuota_fija (french system)" do
      it "produces a fixed payment amount each period that fully amortizes the balance" do
        credit = create(
          :credit,
          principal_amount: 20_000_000,
          term_months: 12,
          interest_rate_ea: 18.5,
          amortization_system: :cuota_fija
        )

        schedule = described_class.new(credit).upcoming_installments

        expect(schedule.size).to eq(12)
        payments = schedule.map(&:payment)
        # every installment has the same payment amount, except the last one which
        # absorbs any rounding drift so the balance lands exactly on zero
        expect(payments.first(11).uniq.size).to eq(1)
        expect(schedule.last.balance).to eq(0)
        expect(schedule.map(&:number)).to eq((1..12).to_a)
      end

      it "starts the schedule the month after first_payment_date when no payments exist" do
        credit = create(
          :credit,
          first_payment_date: Date.new(2026, 8, 5),
          term_months: 6
        )

        schedule = described_class.new(credit).upcoming_installments

        expect(schedule.first.date).to eq(Date.new(2026, 8, 5))
        expect(schedule.second.date).to eq(Date.new(2026, 9, 5))
      end

      it "continues the schedule from the month after the last installment payment" do
        credit = create(:credit, term_months: 12, first_payment_date: Date.new(2026, 1, 5))
        create(:payment, credit: credit, payment_type: :installment, payment_date: Date.new(2026, 1, 5), principal_component: 500_000)

        schedule = described_class.new(credit).upcoming_installments

        expect(schedule.first.date).to eq(Date.new(2026, 2, 5))
      end
    end

    context "with amortization_system abono_constante (german system)" do
      it "keeps the principal portion constant and fully amortizes the balance" do
        credit = create(
          :credit,
          principal_amount: 12_000_000,
          term_months: 12,
          interest_rate_ea: 18.5,
          amortization_system: :abono_constante
        )

        schedule = described_class.new(credit).upcoming_installments

        expect(schedule.size).to eq(12)
        principals = schedule.map(&:principal)
        expect(principals.first(11).uniq.size).to eq(1) # constant principal portion
        expect(schedule.last.balance).to eq(0)
        expect(schedule.first.payment).to be > schedule.last.payment # decreasing total payment
      end
    end

    it "returns an empty schedule once the credit is fully paid off" do
      credit = create(:credit, principal_amount: 1_000_000, term_months: 1)
      create(:payment, credit: credit, payment_type: :installment, principal_component: 1_000_000)

      expect(described_class.new(credit).upcoming_installments).to eq([])
    end

    it "returns an empty schedule when amortization_system is blank" do
      credit = Credit.new(
        principal_amount: 1_000_000, term_months: 12, interest_rate_ea: 18.5,
        first_payment_date: Date.current, amortization_system: nil
      )

      expect(described_class.new(credit).upcoming_installments).to eq([])
    end
  end

  describe "#next_installment" do
    it "returns the first upcoming installment" do
      credit = create(:credit, term_months: 6)

      next_installment = described_class.new(credit).next_installment

      expect(next_installment.number).to eq(1)
      expect(next_installment).to eq(described_class.new(credit).upcoming_installments.first)
    end

    it "returns nil when there is nothing left to schedule" do
      credit = create(:credit, principal_amount: 1_000_000, term_months: 1)
      create(:payment, credit: credit, payment_type: :installment, principal_component: 1_000_000)

      expect(described_class.new(credit).next_installment).to be_nil
    end
  end
end
