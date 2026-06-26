# frozen_string_literal: true

module SongMediaHelper
  def song_media_kind_options
    SongMedium::KINDS.map { |r| [t("activerecord.attributes.song_medium.enums.kind.#{r}"), r] }
  end

  def song_media_register_options
    Register::Song::REGISTERS.map { |r| [t("activerecord.attributes.song.enums.register.#{r}"), r] }
  end

  def file_icon(song_medium)
    tabler_icon(if song_medium.type_audio?
                  :'file-music'
                elsif song_medium.type_pdf?
                  :'file-type-pdf'
                elsif song_medium.type_video?
                  :video
                else
                  :file
                end, classes: ['mr-2'])
  end
end
