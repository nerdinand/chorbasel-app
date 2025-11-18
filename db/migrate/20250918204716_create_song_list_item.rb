# frozen_string_literal: true

class CreateSongListItem < ActiveRecord::Migration[8.0]
  def change
    create_table :song_list_items do |t|
      t.belongs_to :song_list, null: false
      t.belongs_to :song
      t.string :name, null: false
      t.integer :position, null: false
      t.text :notes

      t.index %i[song_list_id position], unique: true, name: 'index_song_list_itemss_on_song_list_id_and_position'

      t.timestamps
    end
  end
end
