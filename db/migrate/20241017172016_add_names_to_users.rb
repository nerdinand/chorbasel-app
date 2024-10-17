# frozen_string_literal: true

class AddNamesToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :first_name, :string, default: '', null: false
    add_column :users, :last_name, :string, default: '', null: false
    add_column :users, :nick_name, :string
  end
end
