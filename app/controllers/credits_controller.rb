class CreditsController < ApplicationController
  def index
    @credits = Current.user.credits.includes(:credit_type).order(created_at: :desc)
    @schedules = @credits.index_with { |credit| Credits::AmortizationSchedule.new(credit) }
  end
end
