# frozen_string_literal: true

class Role
  def initialize(role)
    @role = role
  end

  def human_name
    I18n.t("activerecord.attributes.role.enums.role.#{@role}")
  end

  def value
    @role
  end
end
