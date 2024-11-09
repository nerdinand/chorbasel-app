# frozen_string_literal: true

module SongMediaHelper
  def song_media_kind_options
    SongMedium::KINDS.map { |r| [t("activerecord.attributes.song_medium.enums.kind.#{r}"), r] }
  end

  def song_media_register_options
    Register::Song::REGISTERS.map { |r| [t("activerecord.attributes.song.enums.register.#{r}"), r] }
  end
end
