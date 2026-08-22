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
      if events.many? || !events.first.rrule.empty?
        resolve_occurrences(events)
      else
        events.first
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

      raise "Can't handle more than one recurring event with the same uid." unless recurring_events.one?

      resolve_changed_occurrences(recurring_events.first, changed_events)
    end
  end

  def resolve_simple_occurrences(event)
    event.all_occurrences.map.with_index { |o, i| CalendarOccurrence.new(o, i) }
  end

  def resolve_changed_occurrences(recurring_event, changed_events)
    events = resolve_simple_occurrences(recurring_event)
    changed_events_recurrence_ids = changed_events.map(&:recurrence_id)
    unchanged_occurrences = events.delete_if { |e| e.dtstart.in? changed_events_recurrence_ids }
    unchanged_occurrences + changed_events
  end
end
