# frozen_string_literal: true

class DropCalendarEventIdFromSongLists < ActiveRecord::Migration[8.1]
  def change
    remove_column :song_lists, :calendar_event_id, :integer
  end
end
