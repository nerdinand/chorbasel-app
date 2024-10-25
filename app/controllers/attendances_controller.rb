# frozen_string_literal: true

class AttendancesController < ApplicationController
  PAST_EVENTS_FROM = 6.months
  PAST_EVENTS_TO = 1.day

  def index
    users = authorize User.all
    calendar_events = authorize CalendarEvent.past.where(starts_at: PAST_EVENTS_FROM.ago..PAST_EVENTS_TO.from_now)
    attendances = authorize Attendance.where(user: users).where(calendar_event: calendar_events)
    @attendance_table = AttendanceTable.new(attendances, users, calendar_events)
  end
end
