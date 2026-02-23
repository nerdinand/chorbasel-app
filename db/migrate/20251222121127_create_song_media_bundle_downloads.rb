# frozen_string_literal: true

class CreateSongMediaBundleDownloads < ActiveRecord::Migration[8.1]
  def change
    create_table :song_media_bundle_downloads do |t|
      t.string :register
      t.references :song_list
      t.datetime :song_list_updated_at
      t.string :status
      t.text :log
      t.datetime :last_downloaded_at

      t.index(
        %i[song_list_id register],
        unique: true,
        name: 'index_smbd_on_song_list_id_and_register'
      )

      t.timestamps
    end
  end
end
