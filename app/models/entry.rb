# frozen_string_literal: true

class Entry < ApplicationRecord
  monetize :value_cents

  enum kind: { income: 1, expense: 2 }
  enum payment_method: { credit_card: 1, pix: 2 }
  enum category: { general_expenses: 1, entertainment: 2 }

  after_create :invalidate_month_total

  belongs_to :month
  belongs_to :periodic_entry, optional: true

  def invalidate_month_total
    month.invalidate!
  end

  def apply_installments
    month
      .next(installment_total - 1)
      .each_with_index
      .map { |month, index| attributes.excluding('id').merge(month_id: month.id, installment_number: index + 2, installment_total:) }
      .then { |data| Entry.insert_all(data) }
  end

  def sum_value
    return value.cents if income?

    -value.cents
  end
end
