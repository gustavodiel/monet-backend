class PeriodicEntry < ApplicationRecord
  scope :unfinished, -> { where(fulfilled: false) }

  enum interval: { monthly: 1, yearly: 2 }

  after_create :generate_entries_async

  has_many :entries, dependent: :nullify

  belongs_to :start_month, class_name: 'Month'
  belongs_to :end_month, class_name: 'Month', optional: true

  def generate_entries
    return generate_yearly_entries if yearly?

    generate_monthly_entries
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

  def generate_entries_async
    PeriodicEntriesPropagationJob.perform_async(id)
  end

  def generate_yearly_entries
    month = start_month
    loop do
      build_for_month(month).save!

      break if end_month && month == end_month
      break if month.next_year.nil?

      month = month.next_year.public_send(month.name)

      break unless month
    end
  end

  def generate_monthly_entries
    start_month
      .through(end_month, inclusive: true)
      .map { |month| entry_data.merge(periodic_entry_id: id, month_id: month.id) }
      .then { |data| Entry.insert_all(data) }
  end
end
