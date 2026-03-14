# frozen_string_literal: true

class AddTexterToSongs < ActiveRecord::Migration[8.1]
  def change
    add_column :songs, :texter, :string
    rename_column :songs, :composer, :music_composer
  end
end
