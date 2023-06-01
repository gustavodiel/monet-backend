class Month < ApplicationRecord
  include Comparable

  default_scope { includes(:entries) }

  NAMES = {
    january: 1,
    february: 2,
    march: 3,
    april: 4,
    may: 5,
    june: 6,
    july: 7,
    august: 8,
    september: 9,
    october: 10,
    november: 11,
    december: 12,
  }

  enum name: NAMES

  before_create :check_periodics
  after_create :calculate

  monetize :total_cents, allow_nil: true

  has_many :entries, dependent: :destroy
  has_many :start_periodic_entries, class_name: 'PeriodicEntry', foreign_key: :start_month_id, inverse_of: :start_month, dependent: :destroy
  has_many :end_periodic_entries, class_name: 'PeriodicEntry', foreign_key: :end_month_id, inverse_of: :end_month, dependent: :nullify

  belongs_to :year

  delegate :last_year, :next_year, :last_year!, :next_year!, to: :year

  def self.through(starting_month, ending_month, inclusive: false)
    gt = inclusive ? '>=' : '>'
    lt = inclusive ? '<=' : '<'

    Month.find_by_sql(<<-SQL.squish
      SELECT  e.*
        FROM months e
        JOIN years ye ON e.year_id = ye.id
        WHERE month_index(e.name, ye.name) #{gt} month_index(#{starting_month.numeric_month}, #{starting_month.year.name})
          AND month_index(e.name, ye.name) #{lt} month_index(#{ending_month.numeric_month}, #{ending_month.year.name})
        ORDER BY ye.name, name;
    SQL
    )
  end

  def self.next(starting_month, number)
    return [] unless (end_month = starting_month.numeric_month)
    return [] unless (end_year = starting_month.year.name)

    Month.find_by_sql(<<-SQL.squish
      SELECT  e.*
      FROM months e
      JOIN years ye ON e.year_id = ye.id
      WHERE month_index(e.name, ye.name) > month_index(#{end_month}, #{end_year})
        AND month_index(e.name, ye.name) <= month_index(#{end_month}, #{end_year}) + #{number}
      ORDER BY ye.name, name;
    SQL
    )
  end

  def as_json(options = nil)
    return super unless association(:entries).loaded?

    super.merge(entries: entries.as_json)
  end

  def invalidate!
    invalidate
    year.months_after(self).map(&:invalidate)
  end

  def invalidate
    update(total: nil)
  end

  def calculate
    return total if total.present?

    self.update(total_cents: entries_total + last_month_value)

    total
  end

  def through(final_month, inclusive: false)
    Month.through(self, final_month, inclusive:)
  end

  def next(number)
    Month.next(self, number)
  end

  def entries_total
    entries.sum(0, &:sum_value)
  end

  def last_month_value
    return 0 if last_month.nil?

    last_month.calculate.cents * (1.0 + (year.interest_rate || 0) / 12000)
  end

  def last_month
    return last_year.december if january? && last_year

    year.months.find_by(name: NAMES[name.to_sym] - 1)
  end

  def next_month
    return next_year.january if december? && next_year

    year.months.find_by(name: NAMES[name.to_sym] + 1)
  end

  def last_month!
    return last_year!.december if january?

    year.months.find_by(name: NAMES[name.to_sym] - 1)
  end

  def next_month!
    return next_year!.january if december?

    year.months.find_by(name: NAMES[name.to_sym] + 1)
  end

  def check_periodics
    periodics = PeriodicEntry.unfinished
    periodics.map do |periodic|
      if periodic.on_month?(self)
        periodic.build_for_month(self).attributes.except('id', 'created_at', 'updated_at')
      end
    end
  end

  def <=>(other)
    (year <=> other.year).nonzero? || numeric_month <=> other.numeric_month
  end

  def numeric_month
    self.class.names[name.to_s]
  end

  alias_method :succ, :next_month
end
