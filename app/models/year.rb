# frozen_string_literal: true

class Year < ApplicationRecord
  default_scope { includes(:months) }

  scope :current, -> { find_by(name: Date.current.year) }

  before_create :create_months

  has_many :months, dependent: :destroy

  def self.at(name)
    Year.find_by(name:)
  end

  def self.at!(name)
    Year.find_by!(name:)
  rescue ActiveRecord::RecordNotFound
    Year.create(name:, interest_rate: 12.75)
  end

  def create_months
    Month::NAMES.each_key do |month_name|
      months.build(name: month_name)
    end
  end

  def months_after(month)
    months.where('months.name > ?', month.numeric_month).order(:name)
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

  def <=>(other)
    name <=> other.name
  end

  alias succ next_year

  Month::NAMES.each do |month_name, _value|
    define_method(month_name) do
      months.find(&"#{month_name}?".to_sym)
    end
  end
end
