class CreditsController < ApplicationController
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
end
