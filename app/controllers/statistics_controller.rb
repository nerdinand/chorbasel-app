# frozen_string_literal: true

class StatisticsController < ApplicationController
  NAME_GUESSES_TIMESPAN = 2.weeks
  LAST_N_CALENDAR_EVENTS = 5

  def index
    authorize :statistics, :index?

    @name_guess_counts = calculate_name_guess_counts
    calendar_events = CalendarEvent.unscoped.practice.order(starts_at: :desc).past
                                   .limit(LAST_N_CALENDAR_EVENTS).includes(attendances: [:user]).reverse
    @attendance_tally_table = AttendanceTallyTable.new(calendar_events)
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
end
