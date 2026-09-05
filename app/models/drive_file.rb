# frozen_string_literal: true

class DriveFile
  def initialize(drive_files, file)
    @drive_files = drive_files
    @file = file
  end

  def parent
    @drive_files.files_by_id[@file.parents.try(:first)]
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
