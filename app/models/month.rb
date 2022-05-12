class Month < ApplicationRecord
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

  monetize :total_cents, allow_nil: true

  has_many :entries, dependent: :destroy

  belongs_to :year

  delegate :last_year, :next_year, to: :year

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
      self.total = result
      self.save!
    end
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
end
