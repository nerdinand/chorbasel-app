# frozen_string_literal: true

class StatisticsController < ApplicationController
  NAME_GUESSES_TIMESPAN = 2.weeks

  def index
    authorize :statistics, :index?
    min_date = NAME_GUESSES_TIMESPAN.ago.to_date
    date_range = (min_date..Time.zone.today).to_a
    correct_counts = name_guess_counts(date_range, true)
    incorrect_counts = name_guess_counts(date_range, false)
    @name_guess_counts = [
      { name: 'correct', data: correct_counts },
      { name: 'incorrect', data: incorrect_counts }
    ]
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
end
