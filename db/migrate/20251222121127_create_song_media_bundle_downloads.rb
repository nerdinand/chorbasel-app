# frozen_string_literal: true

class CreateSongMediaBundleDownloads < ActiveRecord::Migration[8.1]
  def change
    create_table :song_media_bundle_downloads do |t|
      t.string :register
      t.references :song_list
      t.time :song_list_updated_at
      t.string :status
      t.text :log
      t.time :last_downloaded_at

      t.timestamps
    end
  end
end
