# frozen_string_literal: true

require 'singleton'

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

  def drive_files
    DriveFiles.new(retrieve_files)
  end

  def retrieve_files(next_page_token = nil)
    response = request_files(next_page_token)

    return response.files unless response.next_page_token

    response.files + retrieve_files(response.next_page_token)
  end

  def download(id)
    buffer = StringIO.new
    drive_service.get_file(
      id, download_dest: buffer, supports_all_drives: true
    )
    buffer.tap(&:rewind)
  end

  private

  def request_files(next_page_token)
    drive_service.list_files(
      q: 'trashed = false',
      page_size: 1000,
      fields: 'files(id, name, mimeType, parents), next_page_token',
      include_items_from_all_drives: true,
      supports_all_drives: true,
      page_token: next_page_token
    )
  end

  attr_reader :drive_service
end
