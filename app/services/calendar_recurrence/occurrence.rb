# frozen_string_literal: true

module CalendarRecurrence
  class Occurrence
    def initialize(occurrence)
      @occurrence = occurrence
    end

    delegate_missing_to :occurrence_parent

    def uid
      "#{occurrence.parent.uid}/#{recurrence_id.rfc3339}"
    end

    def dtstart
      occurrence.start_time
    end

    def dtend
      occurrence.end_time
    end

    def recurrence_id
      occurrence.start_time.in_time_zone
    end

    private

    def occurrence_parent
      occurrence.parent
    end

    attr_reader :occurrence, :index
  end
end
