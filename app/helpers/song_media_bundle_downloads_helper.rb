# frozen_string_literal: true

module SongMediaBundleDownloadsHelper
  def icon_for_song_media_bundle_download_status(status)
    case status
    when 'processing'
      tabler_icon(:loader, classes: ['animate-spin'])
    when 'ready'
      tabler_icon(:check)
    when 'errored'
      tabler_icon(:'alert-triangle')
    end
  end
end
