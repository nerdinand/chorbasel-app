# frozen_string_literal: true

class DashboardController < ApplicationController
  PAST_EVENTS_COUNT = 6

  def show
    @calendar_events = CalendarEvent.next.to_a
    @past_calendar_events = CalendarEvent.past_n(PAST_EVENTS_COUNT).reverse

    @attendance_checks = attendance_checks(@calendar_events + @past_calendar_events)

    @overview_calendar_events = CalendarEvent.where(starts_at: AttendancePagination.new.current_range)
    @timeline_months = DashboardTimeline.new(@calendar_events, upcoming_birthdays).months
    @info = Info.newest_active.first
  end

  private

  def attendance_checks(calendar_events)
    calendar_events.index_with { |ce| AttendanceRestrictionCheck.new(current_user, ce) }
  end

  def upcoming_birthdays
    return {} if @calendar_events.empty?

    last_date = @calendar_events.last.starts_at.to_date
    upcoming_birthdays_query.index_with { |user| Date.parse(user.next_birthday) }
                            .select { |_user, date| date <= last_date }
  end

  def upcoming_birthdays_query
    User.select(
      'users.*', "
    CASE
      WHEN strftime('%m-%d', birth_date) >= strftime('%m-%d', 'now')
      THEN date(strftime('%Y', 'now') || '-' || strftime('%m-%d', birth_date))
      ELSE date((strftime('%Y', 'now') + 1) || '-' || strftime('%m-%d', birth_date))
    END AS next_birthday"
    ).joins(:user_statuses).where(
      'user_statuses.id IN (?) AND users.birth_date IS NOT NULL', active_user_status_ids
    ).order(next_birthday: :asc)
  end

  def active_user_status_ids
    UserStatus.not_inactive.valid_at_time(Time.zone.now).select(:id)
  end
end
