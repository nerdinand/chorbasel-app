# frozen_string_literal: true

class AddUniqueUidSequenceIndexToCalendarEvents < ActiveRecord::Migration[8.1]
  def change
    add_index :calendar_events, %i[uid sequence], unique: true
  end
end
