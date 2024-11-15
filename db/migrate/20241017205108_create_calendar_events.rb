# frozen_string_literal: true

class CreateCalendarEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :calendar_events do |t|
      t.string :uid, null: false
      t.timestamp :event_created_at, null: false
      t.timestamp :starts_at, null: false
      t.timestamp :ends_at, null: false
      t.string :location
      t.string :summary, null: false
      t.string :description, null: false

      t.index :uid, unique: true, name: 'index_calendar_events_on_uid'
      t.index :starts_at, name: 'index_calendar_events_on_starts_at'

      t.timestamps
    end
  end
end
