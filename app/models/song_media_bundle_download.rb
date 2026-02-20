# frozen_string_literal: true

class SongMediaBundleDownload < ApplicationRecord
  belongs_to :song_list

  has_one_attached :file

  # rubocop:disable Naming/VariableNumber
  enum :register,
       {
         soprano_1: 'soprano_1',
         soprano_2: 'soprano_2',
         alto_1: 'alto_1',
         alto_2: 'alto_2',
         tenor_1: 'tenor_1',
         tenor_2: 'tenor_2',
         bass_1: 'bass_1',
         bass_2: 'bass_2'
       }
  # rubocop:enable Naming/VariableNumber

  enum :status, { processing: 'processing', ready: 'ready', errored: 'errored' }, default: :processing

  validates :register, presence: true

  scope :expired, -> { where(last_downloaded_at: ...1.month.ago) }

  def regenerate_if_necessary!
    return unless outdated?

    update(status: :processing)
    SongMediaBundleJob.perform_later(id)
  end

  private

  def outdated?
    return true if song_list_updated_at.nil?

    song_list.last_updated_at > song_list_updated_at
  end
end
