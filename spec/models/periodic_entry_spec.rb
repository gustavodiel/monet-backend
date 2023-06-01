# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PeriodicEntry do
  let!(:y2023) { create(:year, name: 2023) }
  let(:jan_23) { y2023.months.find(&:january?) }
  let(:feb_23) { y2023.months.find(&:february?) }
  let(:dec_23) { y2023.months.find(&:december?) }

  let!(:y2024) { create(:year, name: 2024) }
  let(:jan_24) { y2024.months.find(&:january?) }
  let(:dec_24) { y2024.months.find(&:december?) }

  describe '#generate_entries' do
    context 'when its monthly' do
      let(:periodic_entry) { create(:periodic_entry, start_month: jan_23, end_month: dec_23) }

      it 'generates entries for each month' do
        expect { periodic_entry.generate_entries }.to change(Entry, :count).by(12)

        y2023.months.each do |m|
          expect(m.reload.entries.count).to eq(1)
          expect(m.entries.last.periodic_entry).to eq(periodic_entry)
        end
      end
    end

    context 'when its yearly' do
      let(:periodic_entry) { create(:periodic_entry, :yearly, start_month: jan_23, end_month: dec_24) }

      it 'generates entries for each month' do
        expect { periodic_entry.generate_entries }.to change(Entry, :count).by(2)

        expect(y2023.january.reload.entries.last.periodic_entry).to eq(periodic_entry)
        expect(y2023.february.entries).to be_empty

        expect(y2024.january.reload.entries.last.periodic_entry).to eq(periodic_entry)
        expect(y2024.february.entries).to be_empty
      end
    end
  end
end
