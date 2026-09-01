# frozen_string_literal: true

require 'singleton'

class DriveFiles
  def initialize(all_files)
    @all_files = all_files.map { |f| DriveFile.new(self, f) }
    @files_by_id = @all_files.index_by(&:id)
    @files_by_parent = @all_files.group_by(&:parent)
  end

  def roots
    @files_by_parent[nil]
  end

  attr_reader :files_by_id, :files_by_parent, :all_files
end

class DriveFile
  def initialize(drive_files, file)
    @drive_files = drive_files
    @file = file
  end

  def parent
    @drive_files.files_by_id[@file.parents.try(:first)]
  end

  def children
    @drive_files.files_by_parent[self] || []
  end

  def ancestors
    ancestors = []
    f = self
    until f.nil?
      ancestors << f
      f = f.parent
    end
    ancestors
  end

  def ancestor_names
    ancestors.map(&:name).reverse
  end

  def folder?
    file.mime_type == 'application/vnd.google-apps.folder'
  end

  def shortcut?
    file.mime_type == 'application/vnd.google-apps.shortcut'
  end

  def file?
    !folder? && !shortcut?
  end

  def audio?
    file.mime_type.starts_with?('audio/') || file.mime_type == 'application/ogg'
  end

  def video?
    file.mime_type.starts_with? 'video/'
  end

  def pdf?
    file.mime_type == 'application/pdf'
  end

  def media_file?
    audio? || video? || pdf?
  end

  def download
    buffer = StringIO.new
    SongMediaStorageAccessor.instance.get_file(
      id, download_dest: buffer, supports_all_drives: true
    )
    buffer
  end

  delegate :id, :name, :size, to: :file

  attr_reader :file
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

  def drive_files
    DriveFiles.new(retrieve_files)
  end

  def retrieve_files(next_page_token = nil)
    response = drive_service.list_files(
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

  delegate :get_file, to: :drive_service

  private

  attr_reader :drive_service
end
