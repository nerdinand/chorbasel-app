# frozen_string_literal: true

module CalendarRecurrence
  class ChangedOccurrence
    def initialize(event)
      @event = event
    end

    def uid
      "#{event.uid}/#{event.recurrence_id.rfc3339}"
    end

    delegate_missing_to :event

    private

    attr_reader :event
  end
end
