# frozen_string_literal: true

class Role
  def initialize(role)
    @role = role
  end

  def human_name
    # i18n-tasks-use t('activerecord.attributes.role.enums.role')
    I18n.t("activerecord.attributes.role.enums.role.#{@role}")
  end

  def value
    @role
  end
end
