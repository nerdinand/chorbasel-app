# frozen_string_literal: true

class CreateAttendances < ActiveRecord::Migration[8.0]
  def change
    create_table :attendances do |t|
      t.string :status, null: false
      t.references :calendar_event, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false

      t.index %i[calendar_event_id user_id], unique: true, name: 'index_attendances_on_calendar_event_id_and_user_id'

      t.timestamps
    end
  end
end
