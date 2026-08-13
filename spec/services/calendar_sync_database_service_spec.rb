# frozen_string_literal: true

# rubocop:disable RSpec/MultipleExpectations,RSpec/ExampleLength

require 'rails_helper'

RSpec.describe CalendarSyncDatabaseService do
  subject(:service) { described_class.new }

  describe '#perform!' do
    before do
      CalendarEvent.destroy_all

      CalendarEvent.create!(
        uid: 'A',
        summary: 'A',
        description: '',
        location: '',
        sequence: 0,
        event_created_at: Time.zone.parse('2026-08-01T02:00:00'),
        starts_at: Time.zone.parse('2026-08-01T20:00:00'),
        ends_at: Time.zone.parse('2026-08-01T21:00:00')
      )
    end

    context "when there's an existing event" do
      let(:ics_content) { Rails.root.join('spec/fixtures/files/icalendar/update_A.ics').read }

      it 'updates the event' do
        events = OccurrenceResolver.parse_and_resolve(ics_content)
        service.perform!(events)

        calendar_event = CalendarEvent.find_by(uid: 'A')
        expect(calendar_event.starts_at).to eq(Time.zone.parse('2026-08-01T22:00:00'))
        expect(calendar_event.ends_at).to eq(Time.zone.parse('2026-08-01T23:00:00'))
        expect(calendar_event.summary).to eq('A 2')
        expect(calendar_event.sequence).to eq(1)

        expect(service.created_count).to eq(0)
        expect(service.updated_count).to eq(1)
        expect(service.deleted_count).to eq(0)
        expect(service.unchanged_count).to eq(0)
      end
    end

    context "when there's a new event" do
      let(:ics_content) { Rails.root.join('spec/fixtures/files/icalendar/create_B.ics').read }

      it 'creates a new event' do
        events = OccurrenceResolver.parse_and_resolve(ics_content)
        service.perform!(events)

        calendar_event = CalendarEvent.find_by(uid: 'B')
        expect(calendar_event.starts_at).to eq(Time.zone.parse('2026-08-01T20:00:00'))
        expect(calendar_event.ends_at).to eq(Time.zone.parse('2026-08-01T21:00:00'))
        expect(calendar_event.summary).to eq('B')
        expect(calendar_event.sequence).to eq(0)

        expect(service.created_count).to eq(1)
        expect(service.updated_count).to eq(0)
        expect(service.deleted_count).to eq(0)
        expect(service.unchanged_count).to eq(1)
      end
    end

    context 'when an event is removed' do
      let(:ics_content) { Rails.root.join('spec/fixtures/files/icalendar/delete_A.ics').read }

      it 'deletes the event' do
        events = OccurrenceResolver.parse_and_resolve(ics_content)
        service.perform!(events)

        calendar_event = CalendarEvent.find_by(uid: 'A')
        expect(calendar_event).to be_nil

        expect(service.created_count).to eq(0)
        expect(service.updated_count).to eq(0)
        expect(service.deleted_count).to eq(1)
        expect(service.unchanged_count).to eq(0)
      end
    end
  end
end

# rubocop:enable RSpec/MultipleExpectations,RSpec/ExampleLength
