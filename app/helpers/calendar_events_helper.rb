# frozen_string_literal: true

module CalendarEventsHelper
  DATE_FORMAT = '%d.%m.%Y'
  TIME_FORMAT = '%H:%M'
  DATE_AND_TIME_FORMAT = "#{DATE_FORMAT} #{TIME_FORMAT}".freeze

  def calendar_event_time_string(calendar_event)
    if calendar_event.starts_and_ends_on_same_day?
      time_string_same_day(calendar_event)
    else
      time_string_different_day(calendar_event)
    end
  end

  private

  def time_string_same_day(calendar_event)
    date = calendar_event.starts_at.strftime(DATE_FORMAT)
    start_time = calendar_event.starts_at.strftime(TIME_FORMAT)
    end_time = calendar_event.ends_at.strftime(TIME_FORMAT)

    "#{date} #{start_time}-#{end_time} (#{humanize_duration(calendar_event.duration)})"
  end

  def time_string_different_day(calendar_event)
    [
      calendar_event.starts_at.strftime(DATE_AND_TIME_FORMAT),
      '-',
      calendar_event.ends_at.strftime(DATE_AND_TIME_FORMAT),
      "(#{humanize_duration(calendar_event.duration)})"
    ].join(' ')
  end

  def humanize_duration(duration)
    duration_parts = duration.parts
    { days: 'd', hours: 'h', minutes: 'min', seconds: 's' }.map do |part_key, string|
      "#{duration_parts[part_key].floor}#{string}" if duration_parts.key? part_key
    end.compact.join(' ')
  end
end
