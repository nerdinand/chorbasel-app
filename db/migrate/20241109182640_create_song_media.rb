# frozen_string_literal: true

class CreateSongMedia < ActiveRecord::Migration[8.0]
  def change
    create_table :song_media do |t|
      t.integer :song_id, null: false
      t.string :kind, null: false
      t.string :register

      t.index %i[song_id kind register], unique: true, name: 'index_song_media_on_song_id_and_kind_and_register'
      t.timestamps
    end
  end
end
