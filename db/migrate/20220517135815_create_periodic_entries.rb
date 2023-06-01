# frozen_string_literal: true

class CreatePeriodicEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :periodic_entries do |t|
      t.json :entry_data, null: false
      t.references :start_month, null: false, index: true, foreign_key: { to_table: :months }
      t.references :end_month, index: true, foreign_key: { to_table: :months }
      t.integer :interval
      t.boolean :fulfilled, default: false

      t.timestamps
    end

    change_table :entries do |t|
      t.references :periodic_entry
    end
  end
end
