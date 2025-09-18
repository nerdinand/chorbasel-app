# frozen_string_literal: true

module CalendarEventsHelper
  DATE_FORMAT = '%A, %d.%m.%Y'
  TIME_FORMAT = '%H:%M'
  DATE_AND_TIME_FORMAT = "#{DATE_FORMAT} #{TIME_FORMAT}".freeze

  def calendar_event_time_string(calendar_event)
    if calendar_event.starts_and_ends_on_same_day?
      time_string_same_day(calendar_event)
    else
      time_string_different_day(calendar_event)
    end
  end

  def time_ago_in_words_in_or_ago(time)
    if time.future?
      time_ago_in_words(time, scope: 'datetime.distance_in_words.in_duration')
    else
      time_ago_in_words(time, scope: 'datetime.distance_in_words.ago_duration')
    end
  end

  def calendar_event_color_class(calendar_event)
    return 'bg-primary bg-opacity-30' if calendar_event.today?
    return '' if calendar_event.practice?

    'bg-complementary bg-opacity-30'
  end

  private

  def time_string_same_day(calendar_event)
    date = l(calendar_event.starts_at, format: DATE_FORMAT)
    start_time = l(calendar_event.starts_at, format: TIME_FORMAT)
    end_time = l(calendar_event.ends_at, format: TIME_FORMAT)

    "#{date} #{start_time}-#{end_time} (#{humanize_duration(calendar_event.duration)})"
  end

  def time_string_different_day(calendar_event)
    [
      l(calendar_event.starts_at, format: DATE_AND_TIME_FORMAT),
      '-',
      l(calendar_event.ends_at, format: DATE_AND_TIME_FORMAT),
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
