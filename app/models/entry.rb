class Entry < ApplicationRecord
  monetize :value_cents

  enum kind: { income: 1, expense: 2 }
  enum payment_method: { credit_card: 1, pix: 2 }
  enum category: { general_expenses: 1, entertainment: 2 }

  after_create :invalidate_month_total

  belongs_to :month

  def invalidate_month_total
    month.invalidate!
  end

  def apply_installments
    current_month = month.next_month
    (installment_total - 1).times.each do |installment|
      puts "Creating installment #{installment}"
      puts "Month: #{current_month.name} #{current_month.year.name}"

      current_month.entries << Entry.new(self.attributes.excluding('id', 'month_id').merge(installment_number: installment + 2, installment_total:))

      current_month.save!
      current_month = current_month.next_month
    end
  end

  def sum_value
    return value if income?
    -value
  end
end
