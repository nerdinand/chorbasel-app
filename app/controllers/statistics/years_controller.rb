# frozen_string_literal: true

module Statistics
  class YearsController < ApplicationController
    def show
      @year = current_choir_year
      calendar_events = current_year_events
      @calendar_events_by_category = calendar_events.group_by(&:category)

      users = User.user_status_during_time(
        UserStatus::STATUS_ACTIVE,
        last_general_assembly_starts_at,
        next_general_assembly_starts_at
      )

      @year_statistics_table = YearStatisticsTable.new(users, calendar_events.practice)
    end

    private

    def current_choir_year
      "#{last_general_assembly_starts_at.year} / #{next_general_assembly_starts_at.year}"
    end

    def current_year_events
      CalendarEvent.where(
        'starts_at > ? and starts_at <= ?',
        last_general_assembly_starts_at,
        next_general_assembly_starts_at
      )
    end

    def last_general_assembly_starts_at
      CalendarEvent.last_general_assembly.starts_at
    end

    def next_general_assembly_starts_at
      CalendarEvent.next_general_assembly.starts_at
    end
  end
end
