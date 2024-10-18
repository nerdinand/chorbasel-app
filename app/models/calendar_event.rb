# frozen_string_literal: true

class CalendarEvent < ApplicationRecord
  validates :uid, :event_created_at, :starts_at, :ends_at, :summary, presence: true

  scope :future, -> { where('starts_at > ?', Time.zone.now) }
  scope :next, -> { future.order(starts_at: :asc).limit(10) }
end
