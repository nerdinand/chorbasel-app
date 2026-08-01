# frozen_string_literal: true

class AddIsRecurringToCalendarEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :calendar_events, :is_recurring, :boolean, null: false, default: false
  end
end
