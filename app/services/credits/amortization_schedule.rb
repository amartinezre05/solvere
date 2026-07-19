module Credits
  class AmortizationSchedule
    Installment = Struct.new(:number, :date, :payment, :interest, :principal, :balance, keyword_init: true)

    def initialize(credit)
      @credit = credit
    end

    def current_balance
      (credit.principal_amount - principal_paid).round(2)
    end

    def remaining_term_months
      [ credit.term_months - installments_paid_count, 0 ].max
    end

    def next_installment
      upcoming_installments.first
    end

    def upcoming_installments
      return [] if remaining_term_months.zero? || current_balance <= 0

      case credit.amortization_system
      when "cuota_fija"
        french_schedule
      when "abono_constante"
        german_schedule
      else
        []
      end
    end

    private

    attr_reader :credit

    def principal_paid
      credit.payments.sum(:principal_component)
    end

    def installments_paid_count
      credit.payments.installment.count
    end

    def monthly_rate
      (1 + credit.interest_rate_ea / 100.0)**(1.0 / 12) - 1
    end

    def next_payment_date
      last_installment_date = credit.payments.installment.maximum(:payment_date)
      last_installment_date ? last_installment_date.next_month : credit.first_payment_date
    end

    def french_schedule
      n = remaining_term_months
      rate = monthly_rate
      payment = french_payment_amount(current_balance, rate, n)

      build_schedule(n) do |balance|
        interest = (balance * rate).round(2)
        principal = (payment - interest).round(2)
        [ interest, principal ]
      end
    end

    def french_payment_amount(balance, rate, n)
      return (balance / n).round(2) if rate.zero?

      (balance * rate / (1 - (1 + rate)**-n)).round(2)
    end

    def german_schedule
      n = remaining_term_months
      rate = monthly_rate
      principal_installment = (current_balance / n).round(2)

      build_schedule(n) do |balance|
        interest = (balance * rate).round(2)
        [ interest, principal_installment ]
      end
    end

    def build_schedule(n)
      balance = current_balance
      date = next_payment_date

      (1..n).map do |number|
        interest, principal = yield(balance)
        principal = balance if number == n || principal > balance
        balance = (balance - principal).round(2)

        installment = Installment.new(
          number: number,
          date: date,
          payment: (interest + principal).round(2),
          interest: interest,
          principal: principal,
          balance: balance
        )

        date = date.next_month
        installment
      end
    end
  end
end
