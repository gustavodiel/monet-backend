# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Month, type: :model do
  let!(:y2023) { create(:year, name: 2023) }
  let(:jan_23) { y2023.months.find(&:january?) }
  let(:feb_23) { y2023.months.find(&:february?) }
  let(:dec_23) { y2023.months.find(&:december?) }

  let!(:y2024) { create(:year, name: 2024) }
  let(:jan_24) { y2024.months.find(&:january?) }
  let(:dec_24) { y2024.months.find(&:december?) }

  describe '.through' do
    context 'when last month is within the same year' do
      let(:expected_months) { y2023.months - [jan_23, dec_23] }

      it 'returns the months between the two months' do
        expect(Month.through(jan_23, dec_23)).to match_array(expected_months)
      end
    end

    context 'when last month is within the next year' do
      let(:expected_months) { (y2023.months + y2024.months) - [jan_23, dec_24] }

      it 'returns the months between the two months' do
        expect(Month.through(jan_23, dec_24)).to match_array(expected_months)
      end
    end

    context 'when inclusive is true' do
      context 'when last month is within the same year' do
        let(:expected_months) { y2023.months }

        it 'returns the months between the two months' do
          expect(Month.through(jan_23, dec_23, inclusive: true)).to match_array(expected_months)
        end
      end

      context 'when last month is within the next year' do
        let(:expected_months) { (y2023.months + y2024.months) }

        it 'returns the months between the two months' do
          expect(Month.through(jan_23, dec_24, inclusive: true)).to match_array(expected_months)
        end
      end
    end
  end

  describe '.next' do
    context 'when current month is january' do
      it 'returns february' do
        expect(Month.next(jan_23, 1)).to eq([feb_23])
      end

      context 'when count is 4' do
        let(:march) { y2023.months.find(&:march?) }
        let(:april) { y2023.months.find(&:april?) }
        let(:may) { y2023.months.find(&:may?) }

        it 'returns the next 4 months' do
          expect(Month.next(jan_23, 4)).to eq([feb_23, march, april, may])
        end
      end
    end

    context 'when current month is december' do
      let(:feb_24) { y2024.months.find(&:february?) }

      it 'returns the next two months' do
        expect(Month.next(dec_23, 2)).to eq([jan_24, feb_24])
      end
    end
  end

  describe '#invalidate!' do
    it 'invalidates the month total' do
      y2023.months.each do |m|
        m.update(total_cents: 100_00)
        expect(m.total_cents).to eq(100_00)
      end

      jan_23.invalidate!

      y2023.months.each do |m|
        expect(m.reload.total_cents).to eq(nil)
      end
    end
  end

  describe '#calculate' do
    subject(:calculate) { jan_23.reload.calculate.cents }

    context 'when total is already calculated' do
      before { jan_23.update(total_cents: 200_00) }

      it { is_expected.to eq(200_00) }
    end

    context 'when total is not calculated' do
      before { create(:entry, month: jan_23, value_cents: 500_00) }

      it { is_expected.to eq(-500_00) }
    end

    context 'when total is not calculated and there is an income' do
      before { create(:entry, :income, month: jan_23, value_cents: 500_00) }

      it { is_expected.to eq(500_00) }
    end
  end

  describe '#next_month' do
    subject(:next_month) { jan_23.next_month }

    it { is_expected.to eq(feb_23) }

    context 'when its december' do
      subject(:next_month) { dec_23.next_month }

      it { is_expected.to eq(jan_24) }
    end
  end

  describe '#next_year' do
    subject(:next_year) { jan_23.next_year }

    it { is_expected.to eq(y2024) }
  end

  describe '#last_month' do
    subject(:last_month) { feb_23.last_month }

    it { is_expected.to eq(jan_23) }

    context 'when its january' do
      subject(:last_month) { jan_24.last_month }

      it { is_expected.to eq(dec_23) }
    end
  end

  describe '#last_year' do
    subject(:last_year) { jan_24.last_year }

    it { is_expected.to eq(y2023) }
  end
end
