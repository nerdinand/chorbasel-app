# frozen_string_literal: true

require 'rails_helper'

class FakeDriveService
  def list_files(**options); end
  def get_file(id, **options); end
end

Response = Struct.new('Response', :next_page_token, :files)
GoogleDriveFile = Struct.new('GoogleDriveFile', :id, :mime_type, :name, :parents)

RSpec.describe SongMediaStorageAccessor do
  describe '#drive_files' do
    it 'requests files from google drive and builds the hierarchy' do
      accessor = described_class.instance.tap do |s|
        fake_drive_service = FakeDriveService.new
        allow(fake_drive_service).to receive(:list_files).and_return(
          Response.new(
            'next-page-token',
            [GoogleDriveFile.new('id-1', 'mimetype-1', 'name-1', [])]
          ),
          Response.new(
            nil,
            [GoogleDriveFile.new('id-2', 'mimetype-2', 'name-2', ['id-1'])]
          )
        )

        allow(s).to receive(:drive_service).and_return(fake_drive_service)
      end

      drive_files = accessor.drive_files
      expect(drive_files.all_files.length).to eq(2)
      expect(drive_files.files_by_id.length).to eq(2)

      expect(drive_files.all_files.second.parent).to eq(drive_files.all_files.first)
    end
  end
end
