# frozen_string_literal: true

class CreateSongLists < ActiveRecord::Migration[8.0]
  def change
    create_table :song_lists do |t|
      t.belongs_to :calendar_event
      t.string :name
      t.string :status

      t.timestamps
    end
  end
end
