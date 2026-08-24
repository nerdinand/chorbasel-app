# frozen_string_literal: true

class CalendarSyncDatabaseService
  def initialize
    @created_count = 0
    @updated_count = 0
    @deleted_count = 0
    @unchanged_count = 0
  end

  def perform!(events)
    Rails.logger.info 'Syncing events to database...'
    create_or_update_events(events)
    destroy_deleted_events(events)
    Rails.logger.info "Finished syncing events to database: created: #{@created_count}, \
updated: #{@updated_count}, deleted: #{@deleted_count}, unchanged: #{@unchanged_count}"
    { created_count: @created_count, updated_count: @updated_count, deleted_count: @deleted_count,
      unchanged_count: @unchanged_count }
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
      is_recurring: event.is_a?(CalendarRecurrence::Occurrence) ||
                    event.is_a?(CalendarRecurrence::ChangedOccurrence)
    }
  end

  def destroy_deleted_events(events)
    ical_uids = events.map { |event| event.uid.to_s }
    deleted_ical_uids = CalendarEvent.pluck(:uid) - ical_uids
    calendar_events_to_delete = CalendarEvent.where(uid: deleted_ical_uids)
    @deleted_count = calendar_events_to_delete.count
    calendar_events_to_delete.destroy_all
  end

  attr_reader :created_count, :updated_count, :deleted_count, :unchanged_count
end
