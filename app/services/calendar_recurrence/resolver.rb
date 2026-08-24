# frozen_string_literal: true

module CalendarRecurrence
  class Resolver
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
        CalendarRecurrence::Group.new(events).resolve_events
      end.flatten
    end

    private

    attr_reader :ics_content
  end
end
