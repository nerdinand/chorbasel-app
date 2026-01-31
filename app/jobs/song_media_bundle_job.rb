# frozen_string_literal: true

class SongMediaBundleJob < ApplicationJob
  queue_as :default

  def perform(song_media_bundle_download_id)
    song_media_bundle_download = SongMediaBundleDownload.find(song_media_bundle_download_id)

    ActiveRecord::Base.transaction do
      create_and_upload_bundle!(song_media_bundle_download)

      song_media_bundle_download.update!(
        song_list_updated_at: song_media_bundle_download.song_list.last_updated_at,
        status: :ready
      )
    end
  end

  private

  def create_and_upload_bundle!(song_media_bundle_download)
    bundle = create_bundle(song_media_bundle_download)
    bundle.close_write
    bundle.rewind
    song_media_bundle_download.file.attach(
      io: bundle,
      filename: "#{song_media_bundle_download.song_list.name}.zip"
    )
  end

  def create_bundle(song_media_bundle_download)
    Zip::OutputStream.write_buffer do |zos|
      song_media_bundle_download.song_list.song_list_items.has_song.each do |song_list_item|
        filename, data = download_media(song_list_item.song.song_media, song_media_bundle_download.register)
        next if data.nil?

        zos.put_next_entry(filename)
        zos << data
      end
    end
  end

  def download_media(song_media, register)
    recording = recording_for_register(song_media, register)
    return nil if recording.nil?

    [recording.file.filename, recording.file.attachment.download]
  end

  def recording_for_register(song_media, register)
    song_media.recording.find_by(register: register) || song_media.recording.find_by(register: Register::Singer::REGISTER_TO_CANONICAL_REGISTER[register])
  end
end
