# frozen_string_literal: true

class MonthsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    respond_to do |format|
      format.json do
        render json: Month.all
      end
    end
  end

  def show
    respond_to do |format|
      format.json { render json: Month.find(params[:id]) }
    end
  end

  def create
    month = Month.create!(month_params.merge(year: YearsHelper.year_from_params(params_month.permit(:year, :year_id))))

    respond_to do |format|
      format.json { render json: month }
    end
  rescue ActiveRecord::ActiveRecordError => e
    respond_to do |format|
      format.json { render json: { error: e.message } }
    end
  end

  private

  def params_month = params.require(:month)
  def month_params = params_month.permit(:name)
end
