# frozen_string_literal: true

module InfosHelper
  def infos_kind_options
    Info::KINDS.map { |r| [t("activerecord.attributes.info.enums.kind.#{r}"), r] }
  end
end
