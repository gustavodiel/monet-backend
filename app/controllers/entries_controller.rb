# frozen_string_literal: true

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

  def create_monthly
    if monthly_month_params[:start_month].nil? && monthly_month_params[:start_month_id].nil?
      raise 'Must have start_month parameter'
    end

    end_month = if monthly_month_params[:end_month].present? || monthly_month_params[:end_month_id].present?
                  month_for_entry(
                    month: monthly_month_params[:end_month], month_id: monthly_month_params[:end_month_id]
                  )
                end
    start_month = month_for_entry(month: monthly_month_params[:start_month],
                                  month_id: monthly_month_params[:start_month_id])

    periodic_entry = PeriodicEntry.create!(
      entry_data: monthly_params,
      interval: :monthly,
      start_month_id: start_month.id,
      end_month:
    )

    respond_to do |format|
      format.json { render json: periodic_entry }
    end
  rescue ActiveRecord::ActiveRecordError => e
    respond_to do |format|
      format.json { render json: { error: e.message } }
    end
  end

  def create
    entry = Entry.create!(entry_params.merge(month: month_for_entry, installment_number:))

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

  def entry_params
    params_entry.permit(
      %i[name description kind value_cents value_currency payment_method category
         origin installment_total paid_at day_of_month_to_pay]
    )
  end

  def monthly_params
    params_entry.permit(
      %i[name description kind value_cents value_currency payment_method category
         origin paid_at day_of_month_to_pay]
    )
  end

  def monthly_month_params
    params_entry.permit(
      %i[start_month start_month_id end_month end_month_id]
    )
  end

  def month_entry_params = params_entry.permit(:month_id, :month, :year, :year_id)

  def installment_number = entry_params[:installment_total].present? ? 1 : nil

  def month_for_entry(params = month_entry_params) = MonthsHelper.month_from_params(params)
end
