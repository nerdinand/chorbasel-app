# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SongMediaBundleJob do
  fixtures :all

  it 'generates the zip file and sets the required attributes on the download' do # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
    song_media_bundle_download = SongMediaBundleDownload.create(
      song_list: song_lists(:concert1),
      register: 'bass_2'
    )

    described_class.perform_now(song_media_bundle_download.id)

    song_media_bundle_download.reload

    file = Zip::File.open_buffer(song_media_bundle_download.file.attachment.blob.download)
    expect(file.entries).not_to be_empty

    expect(song_media_bundle_download.file.attachment.blob.content_type).to eq('application/zip')
    expect(song_media_bundle_download.file.attachment.blob.byte_size).to eq(22)
    expect(song_media_bundle_download.song_list_updated_at).to be_present
    expect(song_media_bundle_download.status).to eq('ready')
  end
end
