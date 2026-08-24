# frozen_string_literal: true

class AddUniqueUidSequenceIndexToCalendarEvents < ActiveRecord::Migration[8.1]
  def change
    remove_index :calendar_events, name: 'index_calendar_events_on_uid'
    add_index :calendar_events, %i[uid sequence], unique: true
  end
end
