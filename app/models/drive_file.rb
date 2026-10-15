# frozen_string_literal: true

class DriveFile
  def initialize(drive_files, file)
    @drive_files = drive_files
    @file = file
  end

  def parent
    @drive_files.files_by_id[@file.parents.try(:first)]
  end

  def ancestor_names
    ancestors.map(&:name).reverse
  end

  delegate :id, :mime_type, :name, :parents, to: :file

  attr_reader :file

  private

  def ancestors
    ancestors = []
    file = self

    until file.nil?
      ancestors << file
      file = file.parent
    end

    ancestors
  end
end
