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
