# frozen_string_literal: true

class StatisticsController < ApplicationController
  NAME_GUESSES_TIMESPAN = 2.weeks
  CREATED_AT_TIMESPAN = UPDATED_AT_TIMESPAN = 1.month
  LAST_N_CALENDAR_EVENTS = 5
  TABLES_WITH_TIMESTAMPS = ActiveRecord::Base.connection.tables - %w[schema_migrations active_storage_variant_records
                                                                     active_storage_attachments active_storage_blobs]

  def index
    authorize :statistics, :index?

    @name_guess_counts = calculate_name_guess_counts
    calendar_events = CalendarEvent.unscoped.practice.order(starts_at: :desc).past
                                   .limit(LAST_N_CALENDAR_EVENTS).includes(attendances: [:user]).reverse
    @attendance_tally_table = AttendanceTallyTable.new(calendar_events)

    @timestamp_tallies = timestamp_tallies
  end

  private

  def name_guess_counts(date_range, correct)
    date_range.index_with(0).merge(
      NameGuess.where(correct:)
              .where('date(created_at) >= ?', date_range.first)
              .group('date(created_at)')
              .count
              .transform_keys { |k| Date.parse(k) }
    )
  end

  def calculate_name_guess_counts
    min_date = NAME_GUESSES_TIMESPAN.ago.to_date
    date_range = (min_date..Time.zone.today).to_a
    correct_counts = name_guess_counts(date_range, true)
    incorrect_counts = name_guess_counts(date_range, false)
    [
      { name: 'correct', data: correct_counts },
      { name: 'incorrect', data: incorrect_counts }
    ]
  end

  def timestamp_tallies
    [
      { name: t('.timestamp_tallies.created'), data: timestamp_tally(CREATED_AT_TIMESPAN, 'created_at') },
      { name: t('.timestamp_tallies.modified'), data: timestamp_tally(UPDATED_AT_TIMESPAN, 'updated_at') }
    ]
  end

  def timestamp_tally(timespan, column)
    min_date = timespan.ago.to_date

    timestamp_occurrences = TABLES_WITH_TIMESTAMPS.flat_map do |name|
      ActiveRecord::Base.connection.query("SELECT date(#{column}) FROM #{name} WHERE #{column} > '#{min_date}';")
    end.flatten.tally

    tally = timestamp_occurrences.transform_keys { |k| Date.parse(k) }

    date_range = (min_date..Time.zone.today).to_a
    date_range.index_with(0).merge(tally)
  end
end
