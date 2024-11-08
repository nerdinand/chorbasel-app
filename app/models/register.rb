# frozen_string_literal: true

module Register
  module Singer
    REGISTER_SOPRANO_1 = 'soprano_1'
    REGISTER_SOPRANO_2 = 'soprano_2'
    REGISTER_ALTO_1 = 'alto_1'
    REGISTER_ALTO_2 = 'alto_2'
    REGISTER_TENOR_1 = 'tenor_1'
    REGISTER_TENOR_2 = 'tenor_2'
    REGISTER_BASS_1 = 'bass_1'
    REGISTER_BASS_2 = 'bass_2'

    REGISTERS = [
      REGISTER_SOPRANO_1,
      REGISTER_SOPRANO_2,
      REGISTER_ALTO_1,
      REGISTER_ALTO_2,
      REGISTER_TENOR_1,
      REGISTER_TENOR_2,
      REGISTER_BASS_1,
      REGISTER_BASS_2
    ].freeze
  end

  module Song
    REGISTER_SOPRANO = 'soprano'
    REGISTER_ALTO = 'alto'
    REGISTER_TENOR = 'tenor'
    REGISTER_BASS = 'bass'
    REGISTER_SOPRANO_1 = 'soprano_1'
    REGISTER_SOPRANO_2 = 'soprano_2'
    REGISTER_MEZZO_SOPRANO = 'mezzo-soprano'
    REGISTER_ALTO_1 = 'alto_1'
    REGISTER_ALTO_2 = 'alto_2'
    REGISTER_TENOR_1 = 'tenor_1'
    REGISTER_TENOR_2 = 'tenor_2'
    REGISTER_BARITONE = 'baritone'
    REGISTER_BASS_1 = 'bass_1'
    REGISTER_BASS_2 = 'bass_2'

    REGISTERS = [
      REGISTER_SOPRANO,
      REGISTER_ALTO,
      REGISTER_TENOR,
      REGISTER_BASS,
      REGISTER_SOPRANO_1,
      REGISTER_SOPRANO_2,
      REGISTER_MEZZO_SOPRANO,
      REGISTER_ALTO_1,
      REGISTER_ALTO_2,
      REGISTER_TENOR_1,
      REGISTER_TENOR_2,
      REGISTER_BARITONE,
      REGISTER_BASS_1,
      REGISTER_BASS_2
    ].freeze

    DEFAULT_REGISTERS = [
      REGISTER_SOPRANO,
      REGISTER_ALTO,
      REGISTER_TENOR,
      REGISTER_BASS
    ]

    def self.all
      REGISTERS.map { |r| Register.new(r) }
    end

    class Register
      def initialize(register)
        @register = register
      end

      def human_name
        I18n.t("activerecord.attributes.song.enums.register.#{@register}")
      end

      def value
        @register
      end
    end
  end
end
