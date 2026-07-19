class CreditsController < ApplicationController
  layout false, only: :estimate

  def index
    @credits = Current.user.credits.includes(:credit_type).order(created_at: :desc)
    @schedules = @credits.index_with { |credit| Credits::AmortizationSchedule.new(credit) }
  end

  def show
    @credit = Current.user.credits.includes(:credit_type, :insurance_policies).find(params[:id])
    @schedule = Credits::AmortizationSchedule.new(@credit)
    @paid_installments = @credit.payments.installment.order(:payment_date)
    @upcoming_installments = @schedule.upcoming_installments
    @payments = @credit.payments.order(:payment_date)
  end

  def new
    @credit = Current.user.credits.build
  end

  def create
    @credit = Current.user.credits.build(credit_params)

    if @credit.save
      redirect_to @credit, notice: "Crédito creado."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @credit = Current.user.credits.find(params[:id])
  end

  def update
    @credit = Current.user.credits.find(params[:id])

    if @credit.update(credit_params)
      redirect_to @credit, notice: "Crédito actualizado."
    else
      render :edit, status: :unprocessable_content
    end
  end

  # Lightweight, unpersisted estimate used by the credit form's Stimulus
  # controller to preview the installment while the user is still typing.
  def estimate
    credit = Credit.new(estimate_params.merge(first_payment_date: Date.current))
    valid_inputs = credit.principal_amount.to_f > 0 && credit.term_months.to_i > 0 && credit.interest_rate_ea.present?

    @estimated_payment = Credits::AmortizationSchedule.new(credit).next_installment&.payment if valid_inputs
  end

  private

  def credit_params
    params.require(:credit).permit(
      :credit_type_id, :lender_name, :principal_amount, :currency,
      :uvr_value_at_disbursement, :term_months, :interest_rate_type,
      :interest_rate_ea, :variable_rate_index, :variable_rate_spread,
      :amortization_system, :down_payment, :disbursement_date,
      :first_payment_date, :payment_day, :grace_period_months,
      :notary_fees, :registration_fees, :appraisal_fee, :origination_fee,
      :management_fee, :gmf_applicable, :collateral_type,
      :collateral_description, :subsidy_amount, :status, :notes
    )
  end

  def estimate_params
    params.permit(:principal_amount, :term_months, :interest_rate_ea, :amortization_system)
  end
end
