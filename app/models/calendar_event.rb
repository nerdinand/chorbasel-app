# frozen_string_literal: true

class CalendarEvent < ApplicationRecord
  ONGOING_TIME_WINDOW_BEFORE = 20.minutes
  ONGOING_TIME_WINDOW_AFTER = 10.minutes

  validates :uid, :event_created_at, :starts_at, :ends_at, :summary, presence: true

  scope :future, -> { where('starts_at > ?', Time.zone.now) }
  scope :next, -> { future.order(starts_at: :asc).limit(10) }
  scope :ongoing, lambda {
    where(ends_at: ONGOING_TIME_WINDOW_BEFORE.ago..).where(starts_at: ..ONGOING_TIME_WINDOW_AFTER.from_now)
  }
end
