# frozen_string_literal: true

class AttendancesController < ApplicationController
  def index
    users = authorize User.all
    calendar_events = authorize CalendarEvent.past
    attendances = authorize Attendance.where(user: users).where(calendar_event: calendar_events)
    @attendance_table = AttendanceTable.new(attendances, users, calendar_events)
  end
end
