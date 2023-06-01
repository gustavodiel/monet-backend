# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Year, type: :model do
  let!(:y2023) { create(:year, name: 2023) }
  let(:jan_23) { y2023.months.find(&:january?) }
  let(:feb_23) { y2023.months.find(&:february?) }

  let!(:y2024) { create(:year, name: 2024) }

  describe '#last_year' do
    it { expect(y2024.last_year).to eq(y2023) }

    context 'when the last year does not exist' do
      it { expect(y2023.last_year).to be_nil }
    end
  end

  describe '#next_year' do
    it { expect(y2023.next_year).to eq(y2024) }

    context 'when the next year does not exist' do
      it { expect(y2024.next_year).to be_nil }
    end
  end

  describe '#months_after' do
    it 'returns the remaining months of that year' do
      expect(y2023.months_after(feb_23)).to match_array(y2023.months - [jan_23, feb_23])
    end
  end

  Month::NAMES.each do |month_name, _value|
    describe "##{month_name}" do
      it { expect(y2023.send("#{month_name}")).to eq(y2023.months.find { |m| m.name == month_name.to_s }) }
    end
  end
end
