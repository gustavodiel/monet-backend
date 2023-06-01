# frozen_string_literal: true

class YearsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    render json: Year.all
  end

  def show
    render json: Year.find_by(name: params[:id]) || Year.find(params[:id])
  end

  def create
    year = Year.create!(year_params)

    respond_to do |format|
      format.json { render json: year }
    end
  rescue ActiveRecord::RecordNotUnique
    respond_to do |format|
      format.json { render json: { error: "Duplicated year #{year_params[:name]}" } }
    end
  end

  private

  def year_params
    params.require(:year).permit(:name, :interest_rate)
  end
end
