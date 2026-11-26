# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardTimeline do
  subject(:months) { described_class.new(calendar_events, birthdays).months }

  let(:practice) { CalendarEvent.new(starts_at: Time.zone.local(2026, 12, 3, 19)) }
  let(:concert) { CalendarEvent.new(starts_at: Time.zone.local(2027, 1, 15, 20)) }
  let(:calendar_events) { [practice, concert] }
  let(:birthdays) { { users(:uwe) => Date.new(2026, 12, 3), users(:marit) => Date.new(2026, 12, 3) } }

  it 'groups the items by month' do
    expect(months.map(&:month)).to eq([Date.new(2026, 12, 1), Date.new(2027, 1, 1)])
  end

  it 'merges birthdays on the same day into one entry' do
    birthday_entries = months.first.items.grep(DashboardTimeline::Birthdays)

    expect(birthday_entries.map(&:users)).to eq([[users(:uwe), users(:marit)]])
  end

  it 'puts events before birthdays on the same day' do
    expect(months.first.items.map(&:class)).to eq([CalendarEvent, DashboardTimeline::Birthdays])
  end

  it 'counts events and birthdays per month' do
    expect(months.map { [it.event_count, it.birthday_count] }).to eq([[1, 2], [1, 0]])
  end

  it 'shows the date only on the first row of a day' do
    expect(months.flat_map { it.rows.map(&:last) }).to eq([true, false, true])
  end

  context 'when there are no birthdays' do
    let(:birthdays) { {} }

    it 'contains only the events' do
      expect(months.flat_map(&:items)).to eq([practice, concert])
    end
  end
end
