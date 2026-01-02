# frozen_string_literal: true

class CreateScores < ActiveRecord::Migration[8.1]
  def change
    create_table :scores do |t|
      t.references :song
      t.json :metadata, default: {}, null: false
      t.timestamps
    end
  end
end
