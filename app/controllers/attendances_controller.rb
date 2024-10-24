# frozen_string_literal: true

class AttendancesController < ApplicationController
  PAST_EVENTS_LIMIT = 20

  def index
    users = authorize User.all
    calendar_events = authorize CalendarEvent.past.limit(PAST_EVENTS_LIMIT)
    attendances = authorize Attendance.where(user: users).where(calendar_event: calendar_events)
    @attendance_table = AttendanceTable.new(attendances, users, calendar_events)
  end
end
