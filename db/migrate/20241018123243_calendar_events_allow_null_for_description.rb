# frozen_string_literal: true

class CalendarEventsAllowNullForDescription < ActiveRecord::Migration[8.0]
  def change
    change_column_null :calendar_events, :description, true
  end
end
