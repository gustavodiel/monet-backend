class PeriodicEntry < ApplicationRecord
  scope :unfinished, -> { where(fulfilled: false) }

  enum interval: { monthly: 1, yearly: 2 }

  after_create :update_months

  has_many :entries, dependent: :nullify

  belongs_to :start_month, class_name: 'Month', dependent: :destroy
  belongs_to :end_month, class_name: 'Month', optional: true

  def update_months
    return update_yearly if yearly?

    update_monthly
  end

  def on_month?(month)
    return false if month < start_month
    return false if end_month && month > end_month

    return month.name == start_month.name if yearly?

    true
  end

  def as_json(options = nil)
    return super unless association(:entries).loaded?

    super.merge(entries: entries.as_json)
  end

  def build_for_month(month)
    month.entries.build(entry_data.merge(periodic_entry: self))
  end

  private

  def update_yearly
    month = start_month
    loop do
      build_for_month(month).save!

      break if end_month && month == end_month

      month = month.next_year.public_send(month.name)

      break unless month
    end
  end

  def update_monthly
    start_month
      .through(end_month)
      .map { |month| entry_data.merge(periodic_entry_id: id, month_id: month.id) }
      .then { |data| Entry.insert_all(data) }
  end
end
