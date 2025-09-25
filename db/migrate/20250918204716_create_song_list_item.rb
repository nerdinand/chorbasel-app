# frozen_string_literal: true

class CreateSongListItem < ActiveRecord::Migration[8.0]
  def change
    create_table :song_list_items do |t|
      t.belongs_to :song_list
      t.belongs_to :song
      t.string :name
      t.integer :order
      t.text :notes

      t.timestamps
    end
  end
end
