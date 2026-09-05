# frozen_string_literal: true

class DriveFiles
  def initialize(all_files)
    @all_files = all_files.map { |f| DriveFile.new(self, f) }
    @files_by_id = @all_files.index_by(&:id)
  end

  attr_reader :files_by_id, :all_files
end
