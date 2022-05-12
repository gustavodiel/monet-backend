module MonthsHelper
  def self.month_from_params(params)
    return Month.find(params[:month_id]) if params[:month_id].present?

    year = YearsHelper.year_from_params(params)

    return year.months.find_by(name: params[:month]) if params[:month].present?

    year.current_month
  end
end
