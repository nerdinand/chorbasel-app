# frozen_string_literal: true

class AddFileIdentifierToSongMedia < ActiveRecord::Migration[8.1]
  def change
    add_column :song_media, :file_identifier, :string
  end
end
