# frozen_string_literal: true

class AttendanceCount
  def initialize(calendar_event, status)
    @calendar_event = calendar_event
    @status = status
  end

  def count
    if status == Attendance::STATUS_UNKNOWN
      calendar_event.active_users_at_time.count - calendar_event.attendances.count
    else
      calendar_event.attendances.with_status(status).count
    end
  end

  private

  attr_reader :calendar_event, :status
end
