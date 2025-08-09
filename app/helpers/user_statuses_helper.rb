# frozen_string_literal: true

module UserStatusesHelper
  STATUS_ICON_MAP = {
    UserStatus::STATUS_ACTIVE => :user_check,
    UserStatus::STATUS_INACTIVE => :user_off,
    UserStatus::STATUS_PAUSED => :user_pause
  }.freeze

  def users_status_options
    UserStatus::STATUSES.map { |r| [t("activerecord.attributes.user_status.enums.status.#{r}"), r] }
  end

  def icon_for_user_status(status)
    status ||= UserStatus::STATUS_INACTIVE
    tabler_icon(STATUS_ICON_MAP[status], classes: ['status-icon'])
  end
end
