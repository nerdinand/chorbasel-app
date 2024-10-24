# frozen_string_literal: true

class AttendanceTable
  def initialize(attendances, users, calendar_events)
    @attendances = attendances
    @users = users
    @calendar_events = calendar_events

    @index = @attendances.to_a.group_by(&:user_id)
  end

  attr_reader :attendances, :users, :calendar_events

  def attendance_for(user, calendar_event)
  end
end
