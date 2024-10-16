# frozen_string_literal: true

class AddRolesToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :roles, :json, default: [], null: false
    add_check_constraint :users, "JSON_TYPE(roles) = 'array'", name: 'users_roles_is_array'
  end
end
