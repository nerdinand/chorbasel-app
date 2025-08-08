# frozen_string_literal: true

module UserStatusesHelper
  def users_status_options
    UserStatus::STATUSES.map { |r| [t("activerecord.attributes.user_status.enums.status.#{r}"), r] }
  end
end
