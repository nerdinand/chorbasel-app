# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false

      t.index 'LOWER(email)', unique: true, name: 'index_users_on_lowercase_email'

      t.timestamps
    end
  end
end
