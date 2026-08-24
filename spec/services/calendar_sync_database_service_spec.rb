# frozen_string_literal: true

# rubocop:disable RSpec/MultipleExpectations, RSpec/ExampleLength, RSpec/NestedGroups

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
        event_created_at: Time.zone.parse('2026-08-01T02:00:00'),
        starts_at: Time.zone.parse('2026-08-01T20:00:00'),
        ends_at: Time.zone.parse('2026-08-01T21:00:00')
      )
    end

    describe 'regular events' do
      context "when there's an existing event" do
        let(:ics_content) { Rails.root.join('spec/fixtures/files/icalendar/update_A.ics').read }

        it 'updates the event' do
          events = OccurrenceResolver.parse_and_resolve(ics_content)
          service.perform!(events)

          calendar_event = CalendarEvent.find_by(uid: 'A')
          expect(calendar_event.starts_at).to eq(Time.zone.parse('2026-08-01T22:00:00'))
          expect(calendar_event.ends_at).to eq(Time.zone.parse('2026-08-01T23:00:00'))
          expect(calendar_event.summary).to eq('A 2')

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

    describe 'recurring events' do
      context 'when syncing a regular recurring event' do
        let(:ics_content) { Rails.root.join('spec/fixtures/files/icalendar/recurring.ics').read }

        it 'creates individual CalendarEvents' do
          events = OccurrenceResolver.parse_and_resolve(ics_content)
          service.perform!(events)

          calendar_event = CalendarEvent.find_by(uid: '5CB0C633-9066-437D-B18E-3C912504FC34-0')
          expect(calendar_event.starts_at).to eq(Time.zone.parse('2026-08-22T15:00:00'))
          expect(calendar_event.ends_at).to eq(Time.zone.parse('2026-08-22T16:00:00'))
          expect(calendar_event.summary).to eq('New Event')

          calendar_event = CalendarEvent.find_by(uid: '5CB0C633-9066-437D-B18E-3C912504FC34-1')
          expect(calendar_event.starts_at).to eq(Time.zone.parse('2026-08-29T15:00:00'))
          expect(calendar_event.ends_at).to eq(Time.zone.parse('2026-08-29T16:00:00'))
          expect(calendar_event.summary).to eq('New Event')

          calendar_event = CalendarEvent.find_by(uid: '5CB0C633-9066-437D-B18E-3C912504FC34-2')
          expect(calendar_event.starts_at).to eq(Time.zone.parse('2026-09-05T15:00:00'))
          expect(calendar_event.ends_at).to eq(Time.zone.parse('2026-09-05T16:00:00'))
          expect(calendar_event.summary).to eq('New Event')

          expect(service.created_count).to eq(3)
          expect(service.updated_count).to eq(0)
          expect(service.deleted_count).to eq(1)
          expect(service.unchanged_count).to eq(0)
        end
      end

      context 'when syncing a recurring event where one of the events has been changed' do
        let(:ics_content) { Rails.root.join('spec/fixtures/files/icalendar/recurring_changed.ics').read }

        it 'creates CalendarEvents for the recurring events and for the changed event, but no duplicates' do
          events = OccurrenceResolver.parse_and_resolve(ics_content)
          service.perform!(events)

          calendar_event = CalendarEvent.find_by(uid: '5CB0C633-9066-437D-B18E-3C912504FC34-0')
          expect(calendar_event.starts_at).to eq(Time.zone.parse('2026-08-22T15:00:00'))
          expect(calendar_event.ends_at).to eq(Time.zone.parse('2026-08-22T16:00:00'))
          expect(calendar_event.summary).to eq('New Event')

          calendar_event = CalendarEvent.find_by(uid: '5CB0C633-9066-437D-B18E-3C912504FC34-1')
          expect(calendar_event.starts_at).to eq(Time.zone.parse('2026-08-29T15:00:00'))
          expect(calendar_event.ends_at).to eq(Time.zone.parse('2026-08-29T16:00:00'))
          expect(calendar_event.summary).to eq('New Event')

          calendar_event = CalendarEvent.find_by(uid: '5CB0C633-9066-437D-B18E-3C912504FC34-2026-09-05 15:00:00 +0200')
          expect(calendar_event.starts_at).to eq(Time.zone.parse('2026-09-06T15:00:00'))
          expect(calendar_event.ends_at).to eq(Time.zone.parse('2026-09-06T16:00:00'))
          expect(calendar_event.summary).to eq('Changed event')

          expect(service.created_count).to eq(3)
          expect(service.updated_count).to eq(0)
          expect(service.deleted_count).to eq(1)
          expect(service.unchanged_count).to eq(0)
        end
      end

      context 'when syncing an orphaned recurrence' do
        let(:ics_content) { Rails.root.join('spec/fixtures/files/icalendar/orphaned_recurrence.ics').read }

        it 'ignores the orphan' do
          events = OccurrenceResolver.parse_and_resolve(ics_content)
          service.perform!(events)

          calendar_event = CalendarEvent.find_by(uid: 'A7D89486-131F-43B1-9C70-3D7F0B0490DD')
          expect(calendar_event.ends_at).to eq(Time.zone.parse('2017-03-15T22:00:00'))

          expect(service.created_count).to eq(1)
          expect(service.updated_count).to eq(0)
          expect(service.deleted_count).to eq(1)
          expect(service.unchanged_count).to eq(0)
        end
      end

      context 'when syncing a weird recurrence' do
        let(:ics_content) { Rails.root.join('spec/fixtures/files/icalendar/recurring_weird.ics').read }

        it 'does something' do
          events = OccurrenceResolver.parse_and_resolve(ics_content)
          service.perform!(events)

          calendar_events_data = CalendarEvent
                                 .where("uid like '61122CD5-BC31-4D0A-852B-05EA7AEA1AD1%'")
                                 .order(:starts_at)
                                 .pluck(:uid, :starts_at, :ends_at, :summary)

          expect(calendar_events_data).to eq(
            [['61122CD5-BC31-4D0A-852B-05EA7AEA1AD1-0',
              Time.zone.parse('2016-01-13T20:00:00'),
              Time.zone.parse('2016-01-13T22:00:00'),
              'Vocale'],
             ['61122CD5-BC31-4D0A-852B-05EA7AEA1AD1-1',
              Time.zone.parse('2016-01-20T20:00:00'),
              Time.zone.parse('2016-01-20T22:00:00'),
              'Vocale'],
             ['61122CD5-BC31-4D0A-852B-05EA7AEA1AD1-2',
              Time.zone.parse('2016-01-27T20:00:00'),
              Time.zone.parse('2016-01-27T22:00:00'),
              'Vocale'],
             ['61122CD5-BC31-4D0A-852B-05EA7AEA1AD1-3',
              Time.zone.parse('2016-02-03T20:00:00'),
              Time.zone.parse('2016-02-03T22:00:00'),
              'Vocale'],
             ['61122CD5-BC31-4D0A-852B-05EA7AEA1AD1-4',
              Time.zone.parse('2016-02-24T20:00:00'),
              Time.zone.parse('2016-02-24T22:00:00'),
              'Vocale'],
             ['61122CD5-BC31-4D0A-852B-05EA7AEA1AD1-5',
              Time.zone.parse('2016-03-02T20:00:00'),
              Time.zone.parse('2016-03-02T22:00:00'),
              'Vocale'],
             ['61122CD5-BC31-4D0A-852B-05EA7AEA1AD1-6',
              Time.zone.parse('2016-03-09T20:00:00'),
              Time.zone.parse('2016-03-09T22:00:00'),
              'Vocale'],
             ['61122CD5-BC31-4D0A-852B-05EA7AEA1AD1-7',
              Time.zone.parse('2016-03-16T20:00:00'),
              Time.zone.parse('2016-03-16T22:00:00'),
              'Vocale'],
             ['61122CD5-BC31-4D0A-852B-05EA7AEA1AD1-8',
              Time.zone.parse('2016-04-06T20:00:00'),
              Time.zone.parse('2016-04-06T22:00:00'),
              'Vocale'],
             ['61122CD5-BC31-4D0A-852B-05EA7AEA1AD1-9',
              Time.zone.parse('2016-04-13T20:00:00'),
              Time.zone.parse('2016-04-13T22:00:00'),
              'Vocale'],
             ['61122CD5-BC31-4D0A-852B-05EA7AEA1AD1-2016-04-20 20:00:00 +0200',
              Time.zone.parse('2016-04-20T19:55:00'),
              Time.zone.parse('2016-04-20T22:00:00'),
              'Vocale (bzw. alle)'],
             ['61122CD5-BC31-4D0A-852B-05EA7AEA1AD1-2016-04-27 20:00:00 +0200',
              Time.zone.parse('2016-04-27T20:00:00'),
              Time.zone.parse('2016-04-27T22:00:00'),
              'Vocale  (bzw. alle)'],
             ['61122CD5-BC31-4D0A-852B-05EA7AEA1AD1-2016-05-04 20:00:00 +0200',
              Time.zone.parse('2016-05-04T20:30:00'),
              Time.zone.parse('2016-05-04T22:30:00'),
              'Gesamtprobe'],
             ['61122CD5-BC31-4D0A-852B-05EA7AEA1AD1-2016-05-11 20:00:00 +0200',
              Time.zone.parse('2016-05-11T20:00:00'),
              Time.zone.parse('2016-05-11T22:00:00'),
              'Vocale  (bzw. alle)'],
             ['61122CD5-BC31-4D0A-852B-05EA7AEA1AD1-2016-05-18 20:00:00 +0200',
              Time.zone.parse('2016-05-18T19:55:00'),
              Time.zone.parse('2016-05-18T22:00:00'),
              'VoCantiVox: Gesamtprobe']]
          )

          expect(service.created_count).to eq(15)
          expect(service.updated_count).to eq(0)
          expect(service.deleted_count).to eq(1)
          expect(service.unchanged_count).to eq(0)
        end
      end
    end
  end
end

# rubocop:enable RSpec/MultipleExpectations, RSpec/ExampleLength, RSpec/NestedGroups
