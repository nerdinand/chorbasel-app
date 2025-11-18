# frozen_string_literal: true

class CreatePrograms < ActiveRecord::Migration[8.1]
  def change
    create_table :programs do |t|
      t.belongs_to :calendar_event, null: false
      t.belongs_to :song_list, null: false
      t.timestamps
    end
  end
end
