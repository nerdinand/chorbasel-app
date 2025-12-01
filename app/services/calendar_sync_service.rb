# frozen_string_literal: true

class CalendarSyncService
  def initialize(calendar_url)
    @calendar_url = calendar_url
    @calendar_tmp_path = Rails.root.join('tmp/calendar.ics')
    @created_count = 0
    @updated_count = 0
    @deleted_count = 0
  end

  def perform!
    download_file(calendar_url, calendar_tmp_path)
    ical_events = parse_ics(calendar_tmp_path)
    sync_to_database(ical_events)
  end

  private

  attr_reader :calendar_url, :calendar_tmp_path

  def download_file(url, file_path)
    Rails.logger.info 'Downloading calendar file...'
    Down.download(url, destination: file_path)
    Rails.logger.info 'Finished downloading calendar file.'
  end

  def parse_ics(file_path)
    Rails.logger.info 'Parsing calendar file...'
    ics_file = File.open(file_path)
    parsed = Icalendar::Event.parse(ics_file)
    Rails.logger.info 'Finished parsing calendar file.'
    parsed
  end

  def sync_to_database(ical_events)
    Rails.logger.info 'Syncing events to database...'
    create_or_update_events(ical_events)
    delete_deleted_events(ical_events)
    Rails.logger.info "Finished syncing events to database: created: #{@created_count}, \
updated: #{@updated_count}, deleted: #{@deleted_count}"
  end

  def create_or_update_events(ical_events)
    ical_events.each do |ical_event|
      create_or_update_event(ical_event)
    end
  end

  def create_or_update_event(ical_event)
    calendar_event = CalendarEvent.find_or_initialize_by(uid: ical_event.uid.to_s)

    if calendar_event.new_record?
      @created_count += 1
    else
      @updated_count += 1
    end

    calendar_event.update!(calendar_event_attributes(ical_event))
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

  def delete_deleted_events(ical_events)
    ical_uids = ical_events.map { |ical_event| ical_event.uid.to_s }
    deleted_ical_uids = CalendarEvent.pluck(:uid) - ical_uids
    calendar_events_to_delete = CalendarEvent.where(uid: deleted_ical_uids)
    @deleted_count = calendar_events_to_delete.count
    calendar_events_to_delete.destroy_all
  end
end
