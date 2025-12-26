# frozen_string_literal: true

module SongMediaHelper
  def song_media_kind_options
    SongMedium::KINDS.map { |r| [t("activerecord.attributes.song_medium.enums.kind.#{r}"), r] }
  end

  def song_media_register_options
    Register::Song::REGISTERS.map { |r| [t("activerecord.attributes.song.enums.register.#{r}"), r] }
  end

  def file_icon(attachment)
    tabler_icon(if attachment.audio?
                  :'file-music'
                elsif attachment.content_type == 'application/pdf'
                  :'file-type-pdf'
                elsif attachment.video?
                  :video
                end, classes: ['mr-2'])
  end
end
