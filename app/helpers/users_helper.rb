# frozen_string_literal: true

module UsersHelper
  STATUS_ICON_MAP = {
    UsersQueryParams::QUERY_PARAM_FILTER_ACTIVE => :user_check,
    UsersQueryParams::QUERY_PARAM_FILTER_INACTIVE => :user_off,
    UsersQueryParams::QUERY_PARAM_FILTER_PAUSED => :user_pause,
    UsersQueryParams::QUERY_PARAM_FILTER_ALL => :infinity
  }.freeze

  def users_register_options
    Register::Singer::REGISTERS.map { |r| [t("activerecord.attributes.user.enums.register.#{r}"), r] }
  end

  def icon_for_user_filter(status)
    tabler_icon(STATUS_ICON_MAP[status], classes: ['status-icon'])
  end
end
