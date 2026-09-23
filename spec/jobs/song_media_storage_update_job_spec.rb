# frozen_string_literal: true

require 'rails_helper'

MockDriveFile = Struct.new('DriveFile', :id, :mime_type, :name, :parents)

RSpec.describe SongMediaStorageUpdateJob do
  fixtures :all

  it 'synchronises the Google Drive files to the database' do # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
    allow(SongMediaStorageAccessor).to receive(:new)
    allow(SongMediaStorageAccessor.instance).to receive(:drive_files).and_return(
      DriveFiles.new(
        [
          MockDriveFile.new('parent-identifier', 'application/vnd.google-apps.folder', 'Folder', []), # unchanged
          MockDriveFile.new('identifier-1', 'audio/mpeg', 'myfile.mp3', ['parent-identifier']), # rename file -> updated
          MockDriveFile.new('identifier-3', 'video/mp4', 'myfile.mp4', ['parent-identifier']) # created
        ]
      )
    )

    counts = described_class.perform_now

    expect(counts).to eq(
      {
        created_count: 1,
        deleted_count: 1,
        unchanged_count: 1,
        updated_count: 1
      }
    )

    expect(SongMediaStorageEntry.find_by(identifier: 'parent-identifier').attributes).to include(
      {
        'identifier' => 'parent-identifier',
        'mime_type' => 'application/vnd.google-apps.folder',
        'name' => 'Folder',
        'parent_identifier' => nil,
        'parent_identifiers' => [],
        'path' => 'Folder'
      }
    )
    expect(SongMediaStorageEntry.find_by(identifier: 'identifier-1').attributes).to include(
      {
        'identifier' => 'identifier-1',
        'mime_type' => 'audio/mpeg',
        'name' => 'myfile.mp3',
        'parent_identifier' => 'parent-identifier',
        'parent_identifiers' => ['parent-identifier'],
        'path' => 'Folder/myfile.mp3'
      }
    )
    expect(SongMediaStorageEntry.find_by(identifier: 'identifier-2')).to be_nil
    expect(SongMediaStorageEntry.find_by(identifier: 'identifier-3').attributes).to include(
      {
        'identifier' => 'identifier-3',
        'mime_type' => 'video/mp4',
        'name' => 'myfile.mp4',
        'parent_identifier' => 'parent-identifier',
        'parent_identifiers' => ['parent-identifier'],
        'path' => 'Folder/myfile.mp4'
      }
    )
  end
end
