# frozen_string_literal: true

class AddSequenceToCalendarEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :calendar_events, :sequence, :integer, default: -1, null: false
  end
end
