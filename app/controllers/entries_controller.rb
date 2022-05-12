class EntriesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    respond_to do |format|
      format.json do
        render json: Entry.all
      end
    end
  end

  def show
    respond_to do |format|
      format.json { render json: Entry.find(params[:id]) }
    end
  end

  def create
    entry = Entry.create!(entry_params.merge(month: month_for_entry, installment_number: installment_number))

    entry.apply_installments if entry.installment_total.try(:positive?)

    respond_to do |format|
      format.json { render json: entry }
    end
  rescue ActiveRecord::ActiveRecordError => e
    respond_to do |format|
      format.json { render json: { error: e.message } }
    end
  end

  private

  def params_entry = params.require(:entry)
  def entry_params = params_entry.permit(
    %i[name description kind value_cents value_currency payment_method category
     origin installment_total paid_at day_of_month_to_pay]
  )
  def month_entry_params = params_entry.permit(:month_id, :month, :year, :year_id)

  def installment_number = entry_params[:installment_total].present? ? 1 : nil

  def month_for_entry = MonthsHelper.month_from_params(month_entry_params)
end
