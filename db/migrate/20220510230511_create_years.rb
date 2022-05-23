class CreateYears < ActiveRecord::Migration[7.0]
  def change
    create_table :years do |t|
      t.integer :name
      t.float :interest_rate
    end

    add_index :years, :name, unique: true
  end
end
