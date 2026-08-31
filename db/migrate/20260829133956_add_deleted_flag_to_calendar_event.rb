# frozen_string_literal: true

class AddDeletedFlagToCalendarEvent < ActiveRecord::Migration[8.1]
  def change
    add_column :calendar_events, :deleted, :boolean, null: false, default: false
  end
end
