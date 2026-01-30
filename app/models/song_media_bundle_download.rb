# frozen_string_literal: true

class SongMediaBundleDownload < ApplicationRecord
  belongs_to :song_list

  has_one_attached :file

  enum :canonical_register, { soprano: 'soprano', alto: 'alto', tenor: 'tenor', bass: 'bass' }
  enum :status, { processing: 'processing', ready: 'ready', errored: 'errored' }, default: :processing

  validates :canonical_register, presence: true

  scope :expired, -> { where(last_downloaded_at: ...1.month.ago) }

  def human_canonical_register
    I18n.t("activerecord.attributes.song_media_bundle_download.enums.canonical_register.#{canonical_register}")
  end

  def regenerate_if_necessary!
    return unless outdated?

    update(status: :processing)
    SongMediaBundleJob.perform_later(id)
  end

  private

  def outdated?
    song_list.last_updated_at > song_list_updated_at
  end
end
