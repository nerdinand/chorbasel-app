# frozen_string_literal: true

module Register
  class Register
    @@registers = {}

    def initialize(register, parent_register = nil)
      @register = register
      @parent_register = parent_register
      @@registers[register] = self
    end

    def self.look_up(register)
      
      @@registers[register]
    end

    def human_name
      I18n.t("activerecord.attributes.song.enums.register.#{@register}")
    end

    def value
      @register
    end

    def parent_register
      return self if @parent_register.nil?

      @parent_register
    end

    def <=>(other)
      REGISTER_ORDERING.index(self) <=> REGISTER_ORDERING.index(other)
    end
  end

  # SATB (canonical registers)
  REGISTER_SOPRANO = Register.new('soprano')
  REGISTER_ALTO = Register.new('alto')
  REGISTER_TENOR = Register.new('tenor')
  REGISTER_BASS = Register.new('bass')

  # split up SATB
  REGISTER_SOPRANO_1 = Register.new('soprano_1', REGISTER_SOPRANO)
  REGISTER_SOPRANO_2 = Register.new('soprano_2', REGISTER_SOPRANO)
  REGISTER_ALTO_1 = Register.new('alto_1', REGISTER_ALTO)
  REGISTER_ALTO_2 = Register.new('alto_2', REGISTER_ALTO)
  REGISTER_TENOR_1 = Register.new('tenor_1', REGISTER_TENOR)
  REGISTER_TENOR_2 = Register.new('tenor_2', REGISTER_TENOR)
  REGISTER_BASS_1 = Register.new('bass_1', REGISTER_BASS)
  REGISTER_BASS_2 = Register.new('bass_2', REGISTER_BASS)

  # additional registers
  REGISTER_MEZZO_SOPRANO = Register.new('mezzo-soprano', REGISTER_SOPRANO_2)
  REGISTER_BARITONE = Register.new('baritone', REGISTER_BASS_1)

  CANONICAL_REGISTERS = [
    REGISTER_SOPRANO,
    REGISTER_ALTO,
    REGISTER_TENOR,
    REGISTER_BASS
  ].freeze

  SONG_REGISTERS = [
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

  SINGER_REGISTERS = [
    REGISTER_SOPRANO_1,
    REGISTER_SOPRANO_2,
    REGISTER_ALTO_1,
    REGISTER_ALTO_2,
    REGISTER_TENOR_1,
    REGISTER_TENOR_2,
    REGISTER_BASS_1,
    REGISTER_BASS_2
  ].freeze

  REGISTER_ORDERING = [
    REGISTER_SOPRANO_1,
    REGISTER_SOPRANO_2,
    REGISTER_SOPRANO,

    REGISTER_MEZZO_SOPRANO,

    REGISTER_ALTO_1,
    REGISTER_ALTO_2,
    REGISTER_ALTO,

    REGISTER_TENOR_1,
    REGISTER_TENOR_2,
    REGISTER_TENOR,

    REGISTER_BARITONE,

    REGISTER_BASS_1,
    REGISTER_BASS_2,
    REGISTER_BASS,
  ]
end
