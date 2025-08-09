# frozen_string_literal: true

class UserStatusesOverlapValidator < ActiveModel::Validator
  def validate(user_status)
    return unless overlapping_statuses?(user_status, user_status.user)

    user_status.errors.add(:from_date, I18n.t('user_statuses.user_statuses_overlap_validator.error'))
  end

  private

  def overlapping_statuses?(user_status, user)
    ([user_status] + user.user_statuses).uniq.combination(2).any? { |a, b| a.overlap?(b) }
  end
end

class UserStatus < ApplicationRecord
  STATUS_ACTIVE = 'active'
  STATUS_PAUSED = 'paused'
  STATUS_INACTIVE = 'inactive'

  STATUSES = [STATUS_ACTIVE, STATUS_PAUSED, STATUS_INACTIVE].freeze

  belongs_to :user

  validates :status, inclusion: STATUSES, presence: true
  validates :to_date, comparison: { greater_than: :from_date }, if: -> { to_date.present? && from_date.present? }
  validates :to_date, presence: true, if: -> { from_date.blank? }
  validates :from_date, presence: true, if: -> { to_date.blank? }

  validates_with UserStatusesOverlapValidator

  scope :valid_at_time, lambda { |time|
    where('user_statuses.to_date IS NULL OR (? BETWEEN user_statuses.from_date AND user_statuses.to_date)', time)
  }
  scope :active, -> { with_status(UserStatus::STATUS_ACTIVE) }
  scope :with_status, ->(status) { where(status:) }

  def overlap?(user_status)
    return true if self == user_status

    return true if date_range.overlap?(user_status.date_range)

    false
  end

  def date_range
    from_date..to_date
  end

  def human_status
    I18n.t("activerecord.attributes.user_status.enums.status.#{status}")
  end
end
