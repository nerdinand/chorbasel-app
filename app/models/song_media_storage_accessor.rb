# frozen_string_literal: true

require 'singleton'

class DriveFiles
  def initialize(all_files)
    @all_files = all_files.map { |f| DriveFile.new(f) }.group_by(&:parent)
  end

  def roots
    @all_files[nil]
  end
end

class DriveFile
  def initialize(file)
    @file = file
  end

  def parent
    @file.parents.try(:first)
  end
end

class SongMediaStorageAccessor
  include Singleton

  def initialize
    @drive_service = Google::Apis::DriveV3::DriveService.new
    json_key = StringIO.new(Rails.application.credentials.dig(:google_drive, :service_account_json_key))
    @drive_service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: json_key,
      scope: 'https://www.googleapis.com/auth/drive.readonly'
    )
  end

  def files
    DriveFiles.new(retrieve_files)
    # grouped = files.group_by(&:parents)
    # grouped.transform_keys { |k| files.find { |f| f.id == k.first } }
  end

  def retrieve_files(next_page_token = nil)
    response = @drive_service.list_files(
      q: 'trashed = false',
      page_size: 1000,
      fields: 'files(id, name, mimeType, parents), next_page_token',
      include_items_from_all_drives: true,
      supports_all_drives: true,
      page_token: next_page_token
    )

    files = response.files
    files += retrieve_files(response.next_page_token) if response.next_page_token
    files
  end
end
