# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PeriodicEntriesPropagationJob do
  subject(:job) { described_class.new.perform(pe_id) }

  let(:pe_id) { create(:periodic_entry).id }

  it 'calls generate_entries on the periodic entry' do
    expect_any_instance_of(PeriodicEntry).to receive(:generate_entries)
    job
  end
end
