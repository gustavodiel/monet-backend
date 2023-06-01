# frozen_string_literal: true

module YearsHelper
  def self.year_from_params(params)
    return Year.find(params[:year_id]) if params[:year_id].present?
    return Year.find_by(name: params[:year]) if params[:year].present?

    Year.current
  end
end
