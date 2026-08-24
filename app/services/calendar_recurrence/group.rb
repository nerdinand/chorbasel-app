# frozen_string_literal: true

module CalendarRecurrence
  class Group
    def initialize(events)
      @events = events
    end

    def resolve_events
      if should_resolve_occurrences?
        resolve_occurrences
      else
        [main_event].compact
      end
    end

    private

    attr_reader :events

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

    def resolve_occurrences
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
      event.all_occurrences.map.with_index { |o, i| CalendarRecurrence::Occurrence.new(o, i) }
    end

    def resolve_changed_occurrences(recurring_event, changed_events)
      events = resolve_simple_occurrences(recurring_event)
      changed_events_recurrence_ids = changed_events.map(&:recurrence_id)
      unchanged_occurrences = events.delete_if { |e| e.dtstart.in? changed_events_recurrence_ids }
      unchanged_occurrences + changed_events.map { |ce| CalendarRecurrence::ChangedOccurrence.new(ce) }
    end

    def events_identical?(event1, event2)
      event1.instance_variables.all? { |iv| event1.instance_variable_get(iv) == event2.instance_variable_get(iv) }
    end
  end
end
