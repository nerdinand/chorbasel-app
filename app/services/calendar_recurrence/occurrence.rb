# frozen_string_literal: true

module CalendarRecurrence
  class Occurrence
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
end
