# frozen_string_literal: true

class CreateSongs < ActiveRecord::Migration[8.0]
  def change # rubocop:disable Metrics/MethodLength
    create_table :songs do |t|
      t.string :title, null: false
      t.string :composer
      t.string :arranger
      t.text :lyrics
      t.string :key_signature
      t.string :time_signature
      t.string :language
      t.boolean :repertoire, null: false, default: false

      t.column :genres, :json, default: [], null: false
      t.column :registers, :json, default: [], null: false

      t.timestamps
    end

    add_check_constraint :songs, "JSON_TYPE(genres) = 'array'", name: 'songs_genres_is_array'
    add_check_constraint :songs, "JSON_TYPE(registers) = 'array'", name: 'songs_registers_is_array'
  end
end
