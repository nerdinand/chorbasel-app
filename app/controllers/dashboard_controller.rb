# frozen_string_literal: true

class DashboardController < ApplicationController
  UPCOMING_BIRTHDAYS_QUERY = "
SELECT
  id,
  -- Calculate the next occurrence of the birthday in the current year or the next year
  CASE
    WHEN strftime('%m-%d', birth_date) >= strftime('%m-%d', 'now') THEN
      date(strftime('%Y', 'now') || '-' || strftime('%m-%d', birth_date))
    ELSE
      date((strftime('%Y', 'now') + 1) || '-' || strftime('%m-%d', birth_date))
  END AS next_birthday
FROM
  users
WHERE status == 'active' AND birth_date IS NOT NULL
ORDER BY next_birthday ASC
LIMIT 5;
"

  def show
    @calendar_events = CalendarEvent.next
    @attendances = CalendarEvent.ongoing.map do |calendar_event|
      Attendance.find_or_initialize_by(user: current_user, calendar_event:).tap do |attendance|
        attendance.status = Attendance::STATUS_ATTENDED
      end
    end
    @upcoming_birthdays = upcoming_birthdays
  end

  private

  def upcoming_birthdays
    ActiveRecord::Base.connection.execute(UPCOMING_BIRTHDAYS_QUERY).map do |h|
      h.merge(user: User.find(h['id']), next_birthday: Date.parse(h['next_birthday'])).symbolize_keys
    end
  end
end
