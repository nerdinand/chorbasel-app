# frozen_string_literal: true

class AttendanceTable
  def initialize(attendances, users, calendar_events)
    @users = users
    @calendar_events = calendar_events
    @attendances = attendances
    @index = attendances.group_by { |a| "#{a.user_id}-#{a.calendar_event_id}" }
  end

  attr_reader :users, :calendar_events, :attendances

  def attendance_for(user, calendar_event)
    @index["#{user.id}-#{calendar_event.id}"]&.first
  end

  def to_partial_path
    'attendance_table'
  end
end
