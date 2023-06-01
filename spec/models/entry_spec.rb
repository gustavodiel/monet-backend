# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Entry do
  subject(:entry) { create(:entry, value: 100) }

  let(:month) { entry.month }

  it { is_expected.to be_valid }

  describe '#invalidate_month_total' do
    before { month.update(total: 100) }

    it 'invalidates the month total' do
      expect { entry.invalidate_month_total }.to change { month.reload.total }.to(nil)
    end
  end

  describe '#apply_installments' do
    let(:entry) { create(:entry, installment_total: 3) }
    let(:month) { entry.month }

    it 'creates the installments for the following months (2 + the current one)' do
      expect { entry.apply_installments }.to change { Entry.count }.by(2)
      next_month = month.next_month
      expect(next_month.entries.count).to eq(1)

      next_2_month = next_month.next_month
      expect(next_2_month.entries.count).to eq(1)

      expect(next_2_month.next_month.entries).to be_empty
    end
  end

  describe '#sum_value' do
    context 'when entry is income' do
      let(:entry) { create(:entry, :income, value: 100) }

      it 'returns the value' do
        expect(entry.sum_value).to eq(Money.from_cents(10000, "BRL"))
      end
    end

    context 'when entry is expense' do
      it 'returns the value' do
        expect(entry.sum_value).to eq(Money.from_cents(-10000, "BRL"))
      end
    end
  end
end
