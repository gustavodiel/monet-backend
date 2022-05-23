class Year < ApplicationRecord
  default_scope { includes(:months) }

  scope :current, -> { find_by(name: Date.current.year) }

  before_create :create_months

  has_many :months, dependent: :destroy

  def self.at(name)
    Year.find_by(name: name)
  end

  def self.at!(name)
    Year.find_by!(name: name)
  rescue ActiveRecord::RecordNotFound
    Year.create(name: name, interest_rate: 12.75)
  end

  def create_months
    Month::NAMES.keys.each do |month_name|
      self.months.build(name: month_name)
    end
  end

  def months_after(month)
    months.where('months.name > ?', month.name_before_type_cast).order(:name)
  end

  def current_month
    months.find_by(name: Date.current.month)
  end

  def last_year
    Year.at(name - 1)
  end

  def next_year
    Year.at(name + 1)
  end

  def last_year!
    Year.at!(name - 1)
  end

  def next_year!
    Year.at!(name + 1)
  end

  def as_json(options = nil)
    super.merge(months: months.as_json)
  end

  Month::NAMES.each do |month_name, value|
    define_method(month_name) do
      months.find_by(name: value)
    end
  end
end
