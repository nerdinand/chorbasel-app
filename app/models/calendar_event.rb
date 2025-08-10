# frozen_string_literal: true

class CalendarEvent < ApplicationRecord
  NEXT_EVENTS_LIMIT = 10

  ONGOING_TIME_WINDOW_BEFORE = 20.minutes
  ONGOING_TIME_WINDOW_AFTER = 10.minutes

  PRACTICE_KEYWORD = 'probe'
  CONCERT_KEYWORD = 'konzert'

  validates :uid, :event_created_at, :starts_at, :ends_at, :summary, presence: true

  has_many :attendances, dependent: :destroy

  default_scope -> { order(starts_at: :asc) }

  scope :after, ->(time) { where('starts_at > ?', time) }
  scope :before, ->(time) { where(starts_at: ...time) }
  scope :future, -> { after(Time.zone.now) }
  scope :past, -> { before(Time.zone.now) }
  scope :next, -> { future.limit(NEXT_EVENTS_LIMIT) }

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

  scope :practice, -> { where('summary like ?', "%#{PRACTICE_KEYWORD}%") }
  scope :concert, -> { where('summary like ?', "%#{CONCERT_KEYWORD}%") }

  def attendance_statuses
    status_hash = Attendance::STATUSES.index_with do |status|
      attendances.where(status:)
    end
    users_without_attendance = User.user_status_at_time(UserStatus::STATUS_ACTIVE, starts_at) -
                               status_hash.values.reduce(&:+).map(&:user)
    status_hash[Attendance::STATUS_UNKNOWN] += users_without_attendance.map do |user|
      Attendance.new(user:, calendar_event: self)
    end
    status_hash
  end

  def previous
    CalendarEvent.before(starts_at).last
  end

  def next
    CalendarEvent.after(starts_at).first
  end

  def practice?
    summary.downcase.include? PRACTICE_KEYWORD
  end

  def concert?
    summary.downcase.include? CONCERT_KEYWORD
  end

  def duration
    ActiveSupport::Duration.build(ends_at - starts_at)
  end

  def starts_and_ends_on_same_day?
    starts_at.to_time.to_date === ends_at.to_time.to_date # rubocop:disable Style/CaseEquality
  end

  def ongoing?
    starts_at <= ONGOING_TIME_WINDOW_BEFORE.from_now && ends_at >= ONGOING_TIME_WINDOW_AFTER.ago
  end

  def date
    starts_at.strftime('%d.%m.')
  end
end
