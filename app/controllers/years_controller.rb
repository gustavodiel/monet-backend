class YearsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    respond_to do |format|
      format.json do
        render json: Year.all
      end
    end
  end

  def show
    respond_to do |format|
      format.json { render json: Year.find(params[:id]) }
    end
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
