# frozen_string_literal: true

module AttendanceTableBuilder
  extend ActiveSupport::Concern

  EVENTS_FROM = 1.month
  EVENTS_TO = 2.months

  class_methods do
    def build_attendance_table(users)
      calendar_events = CalendarEvent.where(starts_at: EVENTS_FROM.ago..EVENTS_TO.from_now)
      attendances = Attendance.where(user: users).where(calendar_event: calendar_events)
      AttendanceTable.new(attendances, users, calendar_events)
    end
  end
end
