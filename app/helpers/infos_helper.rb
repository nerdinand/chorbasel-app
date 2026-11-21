# frozen_string_literal: true

module InfosHelper
  def infos_kind_options
    # i18n-tasks-use t('activerecord.attributes.info.enums.kind')
    Info::KINDS.map { |r| [t("activerecord.attributes.info.enums.kind.#{r}"), r] }
  end
end
