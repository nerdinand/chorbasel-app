# frozen_string_literal: true

class CalendarImportService
  def initialize
    @calendar_url = Rails.application.credentials[:calendar_url]
    @calendar_tmp_path = Rails.root.join('tmp/calendar.ics')
  end

  def perform!
    download_file(calendar_url, calendar_tmp_path)
    ical_events = parse_ics(calendar_tmp_path)
    sync_to_database(ical_events)
  end

  private

  attr_reader :calendar_url, :calendar_tmp_path

  def download_file(url, file_path)
    Down.download(url, destination: file_path)
  end

  def parse_ics(file_path)
    ics_file = File.open(file_path)
    Icalendar::Event.parse(ics_file)
  end

  def sync_to_database(ical_events)
    ical_events.each do |ical_event|
      update_or_create_calendar_event(ical_event)
    end
  end

  def update_or_create_calendar_event(ical_event)
    CalendarEvent.find_or_initialize_by(uid: ical_event.uid.to_s).update(calendar_event_attributes(ical_event))
  end

  def calendar_event_attributes(ical_event)
    {
      event_created_at: ical_event.created.to_datetime,
      starts_at: ical_event.dtstart.to_datetime,
      ends_at: ical_event.dtend.to_datetime,
      location: ical_event.location.to_s,
      summary: ical_event.summary.to_s,
      description: ical_event.description.to_s
    }
  end
end
