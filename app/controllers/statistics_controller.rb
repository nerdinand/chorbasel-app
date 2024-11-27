# frozen_string_literal: true

class StatisticsController < ApplicationController
  def index
    min_date = NameGuess.pluck('min(date(created_at))').flatten.map { |d| Date.parse d }.first
    date_range = (min_date..Time.zone.today).to_a
    @correct_counts = date_range.index_with(0).merge(NameGuess.where(correct: true)
                                .group('date(created_at)').count.transform_keys { |k| Date.parse(k) })
    @incorrect_counts = date_range.index_with(0).merge(NameGuess.where(correct: false)
                                  .group('date(created_at)').count.transform_keys { |k| Date.parse(k) })
  end
end
