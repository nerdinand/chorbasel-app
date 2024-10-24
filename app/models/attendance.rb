# frozen_string_literal: true

class Attendance < ApplicationRecord
  STATUS_ATTENDED = 'attended'
  STATUS_EXCUSED = 'excused'
  STATUS_UNKNOWN = 'unknown'
  STATUSES = [STATUS_ATTENDED, STATUS_EXCUSED, STATUS_UNKNOWN].freeze

  belongs_to :calendar_event
  belongs_to :user

  validates :status, presence: true, inclusion: STATUSES

  def status_emoji
    case status
    when STATUS_ATTENDED
      '✅'
    when STATUS_EXCUSED
      '❌'
    else
      '❔'
    end
  end
end
