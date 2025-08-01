# frozen_string_literal: true

class Attendance < ApplicationRecord
  STATUS_ATTENDED = 'attended'
  STATUS_EXCUSED = 'excused'
  STATUS_UNKNOWN = 'unknown'
  STATUS_EXCUSE_REQUESTED = 'excuse_requested'
  STATUSES = [STATUS_ATTENDED, STATUS_EXCUSE_REQUESTED, STATUS_EXCUSED, STATUS_UNKNOWN].freeze

  belongs_to :calendar_event
  belongs_to :user

  validates :status, presence: true, inclusion: STATUSES
  validates :remarks, presence: true, if: :excuse_requested?

  scope :excuse_requested, -> { where(status: STATUS_EXCUSE_REQUESTED) }

  def excuse_requested?
    status == STATUS_EXCUSE_REQUESTED
  end

  def accept!
    self.status = STATUS_EXCUSED
  end
end
