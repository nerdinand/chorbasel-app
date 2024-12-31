# frozen_string_literal: true

class AttendanceTable
  EVENTS_FROM = 1.month
  EVENTS_TO = 2.months

  def initialize(users, current_user)
    @users = users

    @calendar_events = CalendarEvent.where(starts_at: EVENTS_FROM.ago..EVENTS_TO.from_now)
    attendances = Attendance.where(user: users).where(calendar_event: calendar_events)
    raise Pundit::NotAuthorizedError unless AttendancePolicy.new(current_user, attendances).index?

    @index = attendances.group_by { |a| "#{a.user_id}-#{a.calendar_event_id}" }
  end

  attr_reader :users, :calendar_events

  def attendance_for(user, calendar_event)
    @index["#{user.id}-#{calendar_event.id}"]&.first
  end
end
