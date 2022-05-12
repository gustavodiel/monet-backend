class CreateMonths < ActiveRecord::Migration[7.0]
  def change
    create_table :months do |t|
      t.integer :name
      t.monetize :total, amount: { null: true, default: nil }
      t.belongs_to :year

      t.timestamps
    end

    add_index :months, [:year_id, :name], unique: true
  end
end
