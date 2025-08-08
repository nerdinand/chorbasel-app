# frozen_string_literal: true

class CreateUserStatuses < ActiveRecord::Migration[8.0]
  def change
    create_table :user_statuses do |t|
      t.integer :user_id
      t.string :status
      t.string :note
      t.date :from_date
      t.date :to_date

      t.timestamps
    end

    User.find_each do |u|
      u.user_statuses.create!(status: u.status, from_date: Time.zone.today)
    end

    remove_column :users, :status, :string, default: 'active'
  end
end
