# frozen_string_literal: true

class CalendarEvent < ApplicationRecord
  ONGOING_TIME_WINDOW_BEFORE = 20.minutes
  ONGOING_TIME_WINDOW_AFTER = 10.minutes

  validates :uid, :event_created_at, :starts_at, :ends_at, :summary, presence: true

  has_many :attendances, dependent: :destroy

  default_scope -> { order(starts_at: :asc) }

  scope :future, -> { where(starts_at: Time.zone.now..) }
  scope :past, -> { where(starts_at: ..Time.zone.now) }
  scope :next, -> { future.limit(10) }

  #     starts_at      ends_at
  #       |             |
  #       v             v
  #
  # |<-b- [----event----] -a->|
  #
  #             ^
  #             |
  #             x
  #
  # The event is ongoing if:      `starts_at - b < x && x < ends_at + a`
  # Which can be reformulated as: `starts_at < x + b && x - a < ends_at`
  scope :ongoing, lambda {
    where(starts_at: ..ONGOING_TIME_WINDOW_BEFORE.from_now).where(ends_at: ONGOING_TIME_WINDOW_AFTER.ago..)
  }
end
