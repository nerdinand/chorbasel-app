# frozen_string_literal: true

class CalendarSyncService
  def initialize(calendar_url)
    @calendar_url = calendar_url
    @calendar_tmp_path = Rails.root.join('tmp/calendar.ics')
    @created_count = 0
    @updated_count = 0
    @deleted_count = 0
    @unchanged_count = 0
  end

  def perform!
    download_file(calendar_url, calendar_tmp_path)
    events = parse_ics(calendar_tmp_path)
    sync_to_database(events)
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
    ics_content = File.read(file_path)
    events = OccurrenceResolver.parse_and_resolve(ics_content)
    Rails.logger.info 'Finished parsing calendar file.'
    events
  end

  def sync_to_database(events)
    Rails.logger.info 'Syncing events to database...'
    create_or_update_events(events)
    destroy_deleted_events(events)
    Rails.logger.info "Finished syncing events to database: created: #{@created_count}, \
updated: #{@updated_count}, deleted: #{@deleted_count}, unchanged: #{@unchanged_count}"
  end

  def create_or_update_events(events)
    events.each do |event|
      create_or_update_event(event)
    end
  end

  def create_or_update_event(event)
    calendar_event = CalendarEvent.find_or_initialize_by(uid: event.uid.to_s)
    calendar_event.attributes = calendar_event_attributes(event)
    save!(calendar_event)
  end

  def save!(calendar_event)
    if calendar_event.new_record?
      @created_count += 1
    elsif calendar_event.changed?
      @updated_count += 1
    else
      @unchanged_count += 1
    end

    calendar_event.save!
  end

  def calendar_event_attributes(event)
    {
      event_created_at: event.created.to_datetime,
      starts_at: event.dtstart.to_datetime,
      ends_at: event.dtend.to_datetime,
      location: event.location.to_s,
      summary: event.summary.to_s,
      description: event.description.to_s,
      is_recurring: event.is_a?(OccurrenceResolver::CalendarOccurrence)
    }
  end

  def destroy_deleted_events(events)
    ical_uids = events.map { |event| event.uid.to_s }
    deleted_ical_uids = CalendarEvent.pluck(:uid) - ical_uids
    calendar_events_to_delete = CalendarEvent.where(uid: deleted_ical_uids)
    @deleted_count = calendar_events_to_delete.count
    calendar_events_to_delete.destroy_all
  end
end
