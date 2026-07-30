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
    events.map do |e|
      if e.rrule.empty?
        e
      else
        resolve_occurrences(e)
      end
    end.flatten
  end

  private

  attr_reader :ics_content

  def resolve_occurrences(event)
    event.all_occurrences.map.with_index { |o, i| CalendarOccurrence.new(o, i) }
  end
end
