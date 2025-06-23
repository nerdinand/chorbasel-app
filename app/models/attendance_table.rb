# frozen_string_literal: true

class AttendanceTable
  EVENTS_FROM = 1.month
  EVENTS_TO = 2.months

  def initialize(users, current_user)
    @users = users
    @current_user = current_user

    raise Pundit::NotAuthorizedError unless AttendancePolicy.new(current_user, attendances).show?
  end

  attr_reader :users

  def attendance_for(user, calendar_event)
    index[key(user.id, calendar_event.id)]&.first
  end

  def calendar_events
    @calendar_events ||= CalendarEvent.where(starts_at: EVENTS_FROM.ago..EVENTS_TO.from_now)
  end

  def attendances
    attendance_scope = AttendancePolicy::Scope.new(@current_user, Attendance).resolve
    @attendances ||= attendance_scope.where(calendar_event: calendar_events)
  end

  def index
    @index ||= attendances.group_by { |a| key(a.user_id, a.calendar_event_id) }
  end

  def key(user_id, calendar_event_id)
    "#{user_id}-#{calendar_event_id}"
  end
end
