# frozen_string_literal: true

module UsersHelper
  def users_register_options
    Register::Singer::REGISTERS.map { |r| [t("activerecord.attributes.user.enums.register.#{r}"), r] }
  end
end
