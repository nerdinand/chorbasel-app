# frozen_string_literal: true

class SongMediaStorageUpdateJob < ApplicationJob
  queue_as :default

  def perform
    @created_count = @updated_count = @deleted_count = @unchanged_count = 0

    do_update!

    { created_count: @created_count, updated_count: @updated_count, deleted_count: @deleted_count,
      unchanged_count: @unchanged_count }
  end

  private

  def do_update!
    drive_files = SongMediaStorageAccessor.instance.drive_files

    ActiveRecord::Base.transaction do
      list = drive_files.all_files.map do |drive_file|
        to_attributes(drive_file)
      end
      identifiers = insert_or_update(list)
      destroy_others(identifiers)
    end
  end

  def to_attributes(drive_file)
    {
      identifier: drive_file.file.id,
      mime_type: drive_file.file.mime_type,
      name: drive_file.file.name,
      parent_identifiers: drive_file.file.parents,
      parent_identifier: drive_file.file.parents.try(&:first),
      path: drive_file.ancestor_names.join('/')
    }
  end

  def insert_or_update(list)
    identifiers = []
    list.each do |attributes|
      entry = SongMediaStorageEntry.find_or_initialize_by(identifier: attributes[:identifier])
      entry.attributes = attributes
      save!(entry)
      identifiers << entry.identifier
    end
    identifiers
  end

  def destroy_others(identifiers)
    entries_to_delete = SongMediaStorageEntry.where.not(identifier: identifiers)
    @deleted_count = entries_to_delete.count
    entries_to_delete.destroy_all
  end

  def save!(entry)
    if entry.new_record?
      @created_count += 1
    elsif entry.changed?
      @updated_count += 1
    else
      @unchanged_count += 1
    end

    entry.save!
  end
end
