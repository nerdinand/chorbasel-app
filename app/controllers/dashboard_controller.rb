# frozen_string_literal: true

class DashboardController < ApplicationController
  EVENTS_FROM = 1.month
  EVENTS_TO = 2.months

  def show
    @calendar_events = CalendarEvent.where(starts_at: EVENTS_FROM.ago..EVENTS_TO.from_now)
    @upcoming_calendar_events = CalendarEvent.next
    @upcoming_birthdays = upcoming_birthdays
    @info = Info.newest_active.first
  end

  private

  def upcoming_birthdays
    upcoming_birthdays_query.to_h { |e| [User.find(e.id), Date.parse(e.next_birthday)] }
  end

  def upcoming_birthdays_query
    User.select(
      'users.id', "
    CASE
      WHEN strftime('%m-%d', birth_date) >= strftime('%m-%d', 'now')
      THEN date(strftime('%Y', 'now') || '-' || strftime('%m-%d', birth_date))
      ELSE date((strftime('%Y', 'now') + 1) || '-' || strftime('%m-%d', birth_date))
    END AS next_birthday"
    ).joins(:user_statuses).where(
      'user_statuses.id IN (?) AND users.birth_date IS NOT NULL', active_user_status_ids
    ).order(next_birthday: :asc).limit(5)
  end

  def active_user_status_ids
    UserStatus.not_inactive.valid_at_time(Time.zone.now).select(:id)
  end
end
