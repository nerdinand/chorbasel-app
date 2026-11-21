# frozen_string_literal: true

class ChangeScoresMetadata < ActiveRecord::Migration[8.1]
  def change
    add_column :scores, :segment_markers, :text, null: false, default: "time,label\n"
    add_column :scores, :measure_markers, :text, null: false, default: "time,measure\n"

    remove_column :scores, :metadata, :json
  end
end
