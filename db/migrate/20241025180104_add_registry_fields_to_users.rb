# frozen_string_literal: true

class AddRegistryFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :salutation, :string
    add_column :users, :street, :string
    add_column :users, :zip_code, :string
    add_column :users, :city, :string
    add_column :users, :phone_number, :string
    add_column :users, :birth_date, :date
    add_column :users, :status, :string, default: 'active'
    add_column :users, :member_since, :string
    add_column :users, :register, :string
    add_column :users, :remarks, :text
  end
end
