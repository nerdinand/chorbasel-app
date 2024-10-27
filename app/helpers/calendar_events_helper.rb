# frozen_string_literal: true

module CalendarEventsHelper
  DATE_FORMAT = '%d.%m.%Y'
  TIME_FORMAT = '%H:%M'
  DATE_AND_TIME_FORMAT = "#{DATE_FORMAT} #{TIME_FORMAT}".freeze

  def calendar_event_time_string(calendar_event) # rubocop:disable Metrics/MethodLength
    starts_at = calendar_event.starts_at
    ends_at = calendar_event.ends_at
    duration = ActiveSupport::Duration.build(ends_at - starts_at)
    starts_and_ends_on_same_day = starts_at.to_time.to_date === ends_at.to_time.to_date # rubocop:disable Style/CaseEquality

    if starts_and_ends_on_same_day
      date = starts_at.strftime(DATE_FORMAT)
      start_time = starts_at.strftime(TIME_FORMAT)
      end_time = ends_at.strftime(TIME_FORMAT)

      "#{date} #{start_time}-#{end_time} (#{humanize_duration(duration)})"
    else
      "#{starts_at.strftime(DATE_AND_TIME_FORMAT)} - #{ends_at.strftime(DATE_AND_TIME_FORMAT)} (#{humanize_duration(duration)})"
    end
  end

  private

  def humanize_duration(duration)
    duration_parts = duration.parts
    { hours: 'h', minutes: 'min', seconds: 's' }.map do |part_key, string|
      "#{duration_parts[part_key]}#{string}" if duration_parts.key? part_key
    end.compact.join(' ')
  end
end
