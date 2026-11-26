# frozen_string_literal: true

# Merges upcoming calendar events and birthdays into month groups for the dashboard.
class DashboardTimeline
  Birthdays = Data.define(:date, :users)

  Month = Data.define(:month, :items) do
    def event_count = items.count { it.is_a?(CalendarEvent) }
    def birthday_count = items.grep(Birthdays).sum { it.users.size }

    # [item, show_date] pairs; the date is shown only on the first row of a day
    def rows
      items.each_with_index.map do |item, index|
        last_item_has_different_date = DashboardTimeline.date_of(items[index - 1]) != DashboardTimeline.date_of(item)
        show_date = index.zero? || last_item_has_different_date
        [item, show_date]
      end
    end
  end

  def self.date_of(item) = item.is_a?(Birthdays) ? item.date : item.starts_at.to_date

  # birthdays: { user => date }
  def initialize(calendar_events, birthdays)
    @calendar_events = calendar_events
    @birthdays = birthdays
  end

  def months
    birthdays = @birthdays.group_by(&:last).map { |date, pairs| Birthdays.new(date:, users: pairs.map(&:first)) }
    items = (@calendar_events + birthdays).sort_by { [self.class.date_of(it), it.is_a?(Birthdays) ? 1 : 0] }

    items.group_by { self.class.date_of(it).beginning_of_month }
         .map { |month, month_items| Month.new(month:, items: month_items) }
  end
end
