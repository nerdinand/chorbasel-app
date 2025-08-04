# frozen_string_literal: true

class AddCanonicalRegisterToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :canonical_register, :string

    User.find_each do |u|
      next if u.register.blank?

      u.update!(canonical_register: u.register.split('_').first)
    end
  end
end
