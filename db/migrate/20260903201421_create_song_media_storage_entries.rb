# frozen_string_literal: true

class CreateSongMediaStorageEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :song_media_storage_entries do |t|
      t.string :identifier, null: false
      t.string :mime_type, null: false
      t.string :name, null: false
      t.json :parent_identifiers
      t.string :parent_identifier
      t.string :path

      t.timestamps

      t.index :identifier, unique: true, name: 'index_song_media_storage_entries_on_identifier'
    end
  end
end
