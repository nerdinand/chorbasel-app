# frozen_string_literal: true

module UsersHelper
  def users_register_options
    User::REGISTERS.map { |r| [t("activerecord.attributes.user.enums.register.#{r}"), r] }
  end

  def users_status_options
    User::STATUSES.map { |r| [t("activerecord.attributes.user.enums.status.#{r}"), r] }
  end
end
