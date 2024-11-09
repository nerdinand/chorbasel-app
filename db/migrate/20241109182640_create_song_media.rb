# frozen_string_literal: true

class CreateSongMedia < ActiveRecord::Migration[8.0]
  def change
    create_table :song_media do |t|
      t.integer :song_id, null: false
      t.string :kind, null: false
      t.string :register

      t.timestamps
    end
  end
end
