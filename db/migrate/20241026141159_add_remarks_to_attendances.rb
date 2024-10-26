# frozen_string_literal: true

class AddRemarksToAttendances < ActiveRecord::Migration[8.0]
  def change
    add_column :attendances, :remarks, :text
  end
end
