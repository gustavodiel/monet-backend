# frozen_string_literal: true

class PeriodicEntriesPropagationJob
  include Sidekiq::Job

  def perform(periodic_entry_id)
    periodic_entry = PeriodicEntry.find(periodic_entry_id)
    periodic_entry.generate_entries
  end
end
