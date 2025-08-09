# frozen_string_literal: true

class AttendanceTable
  def initialize(attendances, users, calendar_events)
    @calendar_events = calendar_events

    @attendances_index = attendances.group_by { |a| "#{a.user_id}-#{a.calendar_event_id}" }
    @canonical_register_users = users.group_by(&:canonical_register)

    @user_statuses_index = calendar_events.index_with do |ce|
      UserStatus.where(user_id: users.select(:id)).valid_at_time(ce.starts_at).index_by(&:user_id)
    end
  end

  attr_reader :canonical_register_users, :calendar_events

  def attendance_for(user, calendar_event)
    @attendances_index["#{user.id}-#{calendar_event.id}"]&.first
  end

  def user_status_for(user, calendar_event)
    @user_statuses_index[calendar_event][user.id]
  end
end
