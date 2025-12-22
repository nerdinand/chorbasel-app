# frozen_string_literal: true

class SongMediaBundleDownload < ApplicationRecord
  belongs_to :song_list

  enum :canonical_register, { soprano: 'soprano', alto: 'alto', tenor: 'tenor', bass: 'bass' }
  enum :status, { processing: 'processing', ready: 'ready', errored: 'errored' }, default: :processing

  validates :canonical_register, presence: true

  def human_canonical_register
    I18n.t("activerecord.attributes.song_media_bundle_download.enums.canonical_register.#{canonical_register}")
  end

  def regenerate_if_necessary!
    # TODO
  end
end
