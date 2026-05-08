# frozen_string_literal: true

class YearStatisticsTable
  def initialize(users, calendar_events)
    @users = users
    @calendar_events = calendar_events
  end

  def active_count(user)
    active_counts.fetch(user.id, 0)
  end

  def count(user, status)
    user_id_status_counts.fetch([user.id, status], 0)
  end

  def active_percentage(user, status)
    active_count = active_count(user)
    return 0.0 if active_count.zero?

    100 * count(user, status).to_f / active_count
  end

  def overall_percentage(user, status)
    100 * count(user, status).to_f / overall_count
  end

  def sorted_users
    @users.sort_by do |u|
      -overall_percentage(u, Attendance::STATUS_ATTENDED)
    end
  end

  attr_reader :users, :calendar_events

  private

  def user_id_status_counts
    @user_id_status_counts ||= begin
      users_attendances = users.joins(:attendances).where('attendances.calendar_event_id': calendar_events.pluck(:id))
      users_attendances.group('users.id', 'attendances.status').count
    end
  end

  def active_counts
    @active_counts ||= users.joins(:user_statuses).active
                            .joins('join calendar_events')
                            .where('calendar_events.id': calendar_events.ids)
                            .where('
                            (
                              user_statuses.from_date < calendar_events.starts_at AND
                              calendar_events.starts_at < user_statuses.to_date
                            )
                            OR (user_statuses.from_date < calendar_events.starts_at AND user_statuses.to_date IS NULL)
                            OR (user_statuses.from_date IS NULL AND calendar_events.starts_at < user_statuses.to_date)')
                            .group('users.id').count
  end

  def calendar_event_dates
    calendar_events.pluck(:starts_at)
  end

  def overall_count
    calendar_events.count
  end
end
