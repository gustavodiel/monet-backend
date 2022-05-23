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

  after_create :check_periodics

  monetize :total_cents, allow_nil: true

  has_many :entries, dependent: :destroy
  has_many :periodic_entries, foreign_key: :start_month_id, inverse_of: :start_month, dependent: :destroy
  has_many :periodic_entries, foreign_key: :end_month_id, inverse_of: :end_month, dependent: :nullify

  belongs_to :year

  delegate :last_year, :next_year, :last_year!, :next_year!, to: :year

  def self.through(starting_month, ending_month)
    end_month = ending_month.try(:name_before_type_cast) || 12
    end_year = ending_month.try { year.name } || 2100

    Month.find_by_sql(<<-SQL.squish
      WITH RECURSIVE month_range AS (
          SELECT months.*, y.name as year_name
          FROM months
          JOIN years y on months.year_id = y.id
          WHERE months.id = #{starting_month.id}
          UNION
              SELECT e.*, ye.name as year_name
              FROM months e
              JOIN years ye on e.year_id = ye.id
              INNER JOIN month_range s ON month_index(e.name, ye.name) = month_index(s.name, s.year_name) + 1 AND month_index(e.name, ye.name) <= month_index(#{end_month}, #{end_year})
      ) SELECT id, name, total_cents, total_currency, year_id, created_at, updated_at FROM month_range ORDER BY year_name, name;
    SQL
    )
  end

  def self.next(starting_month, number)
    end_month = starting_month.name_before_type_cast
    end_year = starting_month.year.name

    Month.find_by_sql(<<-SQL.squish
      WITH RECURSIVE month_range AS (
          SELECT months.*, y.name as year_name
          FROM months
          JOIN years y on months.year_id = y.id
          WHERE months.id = #{starting_month.id}
          UNION
              SELECT e.*, ye.name as year_name
              FROM months e
              JOIN years ye on e.year_id = ye.id
              INNER JOIN month_range s ON month_index(e.name, ye.name) = month_index(s.name, s.year_name) + 1 AND month_index(e.name, ye.name) <= month_index(#{end_month}, #{end_year}) + #{number}
      ) SELECT id, name, total_cents, total_currency, year_id, created_at, updated_at FROM month_range ORDER BY year_name, name;
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

    (entries_total + last_month_value).tap do |result|
      self.value = result
      self.save!
    end
  end

  def through(final_month)
    Month.through(self, final_month)
  end

  def next(number)
    Month.next(self, number)
  end

  def entries_total
    entries.sum(0, &:sum_value)
  end

  def last_month_value
    return 0 if last_month.nil?

    last_month.calculate * (1.0 + year.interest_rate / 12000)
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
    news = periodics.map do |periodic|
      if periodic.on_month?(self)
        periodic.build_for_month(self).attributes.except('id', 'created_at', 'updated_at')
      end
    end

    Entry.insert_all(news.uniq)
  end

  def <=>(other)
    (year <=> other.year).nonzero? || name_before_type_cast <=> other.name_before_type_cast
  end

  alias_method :succ, :next_month
end
