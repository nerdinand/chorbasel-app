# frozen_string_literal: true

class AttendancePagination
  EVENTS_FROM = 1.month
  EVENTS_TO = 2.months
  INTERVAL = EVENTS_FROM + EVENTS_TO

  def initialize(from = nil, to = nil)
    @from = from.present? ? Date.parse(from) : EVENTS_FROM.ago.to_date
    @to = to.present? ? Date.parse(to) : EVENTS_TO.from_now.to_date
  end

  def current_range = from..to
  def previous_params = { from: previous_range.begin, to: previous_range.end }
  def next_params = { from: next_range.begin, to: next_range.end }

  attr_reader :from, :to

  private

  def previous_range = (from - INTERVAL)..from
  def next_range = to..(to + INTERVAL)
end
