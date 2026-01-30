# frozen_string_literal: true

class SongMediaBundleJob < ApplicationJob
  queue_as :default

  def perform(song_media_bundle_download_id)
    sleep(5) # TODO: do the thing instead

    song_media_bundle_download = SongMediaBundleDownload.find(song_media_bundle_download_id)

    song_media_bundle_download.update(
      song_list_updated_at: song_media_bundle_download.song_list.last_updated_at,
      # TODO: update file
      status: :ready
    )
  end
end
