# frozen_string_literal: true

module Statistics
  class AttendancesController < ApplicationController
    def show
      authorize :statistics, :index?

      if params[:from]
        resolve_timeframe
      else
        resolve_year
      end

      calendar_events = CalendarEvent.in_time_range(@timeframe_from, @timeframe_to)
      @calendar_events_by_category = calendar_events.group_by(&:category)
      users = find_users

      @year_statistics_table = AttendanceStatisticsTable.new(users, calendar_events.practice.past)
    end

    private

    def find_users
      User.user_status_during_time(
        UserStatus::STATUS_ACTIVE,
        @timeframe_from,
        @timeframe_to
      )
    end

    def resolve_timeframe
      @timeframe_from = Date.parse(params[:from])
      @timeframe_to = Date.parse(params[:to])
    rescue Date::Error
      @timeframe_from = nil
      @timeframe_to = nil
    end

    def resolve_year
      @year = (params[:year] || CalendarEvent.general_assembly.past.last.starts_at.year).to_i

      @timeframe_from = general_assembly_for_year(@year).try(:starts_at).try(:to_date)
      @timeframe_to = general_assembly_for_year(@year + 1).try(:starts_at).try(:to_date)
    end

    def general_assembly_for_year(year)
      CalendarEvent.general_assembly.where("cast(strftime('%Y', starts_at) as int) = ?", year).first
    end
  end
end
