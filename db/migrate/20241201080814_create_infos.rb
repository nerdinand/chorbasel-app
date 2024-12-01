# frozen_string_literal: true

class CreateInfos < ActiveRecord::Migration[8.0]
  def change
    create_table :infos do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.string :kind, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
