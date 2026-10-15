# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SongMediaBundleDownloadsHelper do
  describe '#icon_for_song_media_bundle_download_status' do
    it 'returns an icon for a status' do
      processing_icon = helper.icon_for_song_media_bundle_download_status('processing')
      expect(processing_icon).to include('class="animate-spin"')

      ready_icon = helper.icon_for_song_media_bundle_download_status('ready')
      expect(ready_icon).to include('class="icon tabler-icon"')

      errored_icon = helper.icon_for_song_media_bundle_download_status('errored')
      expect(errored_icon).to include('class="icon tabler-icon"')
    end
  end
end
