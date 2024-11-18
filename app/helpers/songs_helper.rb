# frozen_string_literal: true

module SongsHelper
  def register_string(registers)
    debugger
    return 'SATB' if registers == Register::CANONICAL_REGISTERS

    registers.map { |r| t("activerecord.attributes.song.enums.register.#{r}") }.join(', ')
  end
end
