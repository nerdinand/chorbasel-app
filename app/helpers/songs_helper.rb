# frozen_string_literal: true

module SongsHelper
  def register_string(registers)
    return 'SATB' if registers == Register::Song::DEFAULT_REGISTERS

    # i18n-tasks-use t('activerecord.attributes.song.enums.register')
    registers.map { |r| t("activerecord.attributes.song.enums.register.#{r}") }.join(', ')
  end
end
