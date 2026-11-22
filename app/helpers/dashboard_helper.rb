# frozen_string_literal: true

module DashboardHelper
  def month_counts(month)
    [
      (t('dashboard.show.month_counts.events', count: month.event_count) if month.event_count.positive?),
      (t('dashboard.show.month_counts.birthdays', count: month.birthday_count) if month.birthday_count.positive?)
    ].compact.join(' · ')
  end
end
