# frozen_string_literal: true

class SongMediaStorageUpdateJob < ApplicationJob
  queue_as :default

  def perform
    @created_entry_identifiers = []
    @updated_entry_identifiers = []
    @deleted_entry_identifiers = []
    @unchanged_entry_identifiers = []

    do_update!

    send_notification_email!

    { created_count:, updated_count:, deleted_count:, unchanged_count: }
  end

  private

  attr_reader :created_entry_identifiers, :updated_entry_identifiers, :deleted_entry_identifiers,
              :unchanged_entry_identifiers

  def created_count
    created_entry_identifiers.count
  end

  def updated_count
    updated_entry_identifiers.count
  end

  def deleted_count
    deleted_entry_identifiers.count
  end

  def unchanged_count
    unchanged_entry_identifiers.count
  end

  def do_update!
    drive_files = SongMediaStorageAccessor.instance.drive_files

    ActiveRecord::Base.transaction do
      list = drive_files.all_files.map do |drive_file|
        attributes_hash(drive_file)
      end
      identifiers = insert_or_update(list)
      destroy_others(identifiers)
    end
  end

  def send_notification_email!
    return unless [created_count, updated_count, deleted_count].any?(&:positive?)

    SongMediaStorageUpdateMailer.with(created_entry_identifiers:, updated_entry_identifiers:,
                                      deleted_entry_identifiers:, unchanged_entry_identifiers:).update_email.deliver_now
  end

  def attributes_hash(drive_file)
    {
      identifier: drive_file.id,
      mime_type: drive_file.mime_type,
      name: drive_file.name,
      parent_identifiers: drive_file.parents,
      parent_identifier: drive_file.parents.try(&:first),
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
    @deleted_entry_identifiers = entries_to_delete.map(&:identifier)
    entries_to_delete.destroy_all
  end

  def save!(entry)
    if entry.new_record?
      created_entry_identifiers << entry.identifier
    elsif entry.changed?
      updated_entry_identifiers << entry.identifier
    else
      unchanged_entry_identifiers << entry.identifier
    end

    entry.save!
  end
end
