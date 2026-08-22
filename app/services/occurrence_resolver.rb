# frozen_string_literal: true

class OccurrenceResolver
  class CalendarOccurrence
    def initialize(occurrence, index)
      @occurrence = occurrence
      @index = index
    end

    delegate_missing_to :occurrence_parent

    def uid
      "#{occurrence.parent.uid}-#{index}"
    end

    def dtstart
      occurrence.start_time
    end

    def dtend
      occurrence.end_time
    end

    private

    def occurrence_parent
      occurrence.parent
    end

    attr_reader :occurrence, :index
  end

  class ChangedCalendarOccurrence
    def initialize(event)
      @event = event
    end

    def uid
      "#{event.uid}-#{event.recurrence_id}"
    end

    delegate_missing_to :event

    private

    attr_reader :event
  end

  class CalendarEventsGroup
    def initialize(events)
      @events = events
    end

    def should_resolve_occurrences?
      return false unless recurring_event
      return false if events.many? && all_identical?

      true
    end

    def all_identical?
      events.all? { |e| events_identical?(events.first, e) }
    end

    def recurring_event
      events.find { |e| !e.rrule.empty? }
    end

    def main_event
      return events.find { |e| e.recurrence_id.nil? } if recurring_event.nil?

      recurring_event
    end

    private

    attr_reader :events

    def events_identical?(event1, event2)
      event1.instance_variables.all? { |iv| event1.instance_variable_get(iv) == event2.instance_variable_get(iv) }
    end
  end

  def initialize(ics_content)
    @ics_content = ics_content
  end

  def self.parse_and_resolve(ics_content)
    new(ics_content).parse_and_resolve
  end

  def parse_and_resolve
    events = Icalendar::Event.parse(ics_content)

    events_by_uid = events.group_by(&:uid)

    events_by_uid.map do |_uid, events|
      group = CalendarEventsGroup.new(events)

      if group.should_resolve_occurrences?
        resolve_occurrences(events)
      else
        group.main_event
      end
    end.flatten
  end

  private

  attr_reader :ics_content

  def resolve_occurrences(events)
    if events.one?
      resolve_simple_occurrences(events.first)
    else # this means at least one of the recurring event instances has been changed
      recurring_events = events.reject { |e| e.rrule.empty? }
      changed_events = events - recurring_events
      recurring_event = recurring_events.first
      resolve_changed_occurrences(recurring_event, changed_events)
    end
  end

  def resolve_simple_occurrences(event)
    event.all_occurrences.map.with_index { |o, i| CalendarOccurrence.new(o, i) }
  end

  def resolve_changed_occurrences(recurring_event, changed_events)
    events = resolve_simple_occurrences(recurring_event)
    changed_events_recurrence_ids = changed_events.map(&:recurrence_id)
    unchanged_occurrences = events.delete_if { |e| e.dtstart.in? changed_events_recurrence_ids }
    unchanged_occurrences + changed_events.map { |ce| ChangedCalendarOccurrence.new(ce) }
  end
end
