# frozen_string_literal: true

class ConvertInfosDescriptionToActiontext < ActiveRecord::Migration[8.1]
  def up
    Info.find_each do |info|
      info.update(content: info.description)
    end

    remove_column :infos, :description, type: :text, null: false
  end

  def down
    add_column :infos, :description, type: :text, null: false
  end
end
