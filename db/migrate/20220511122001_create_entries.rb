class CreateEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :entries do |t|
      t.string :name
      t.text :description
      t.integer :kind
      t.monetize :value
      t.integer :payment_method
      t.integer :category
      t.string :origin
      t.integer :installment_number
      t.integer :installment_total
      t.datetime :paid_at
      t.integer :day_of_month_to_pay

      t.belongs_to :entry

      t.belongs_to :month

      t.timestamps
    end
  end
end
