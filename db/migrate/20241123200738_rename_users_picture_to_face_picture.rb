# frozen_string_literal: true

class RenameUsersPictureToFacePicture < ActiveRecord::Migration[8.0]
  def up
    ActiveRecord::Base.connection.execute("
UPDATE active_storage_attachments SET name = 'face_picture'
WHERE record_type = 'User' AND name = 'picture';
")
  end

  def down
    ActiveRecord::Base.connection.execute("
UPDATE active_storage_attachments SET name = 'picture'
WHERE record_type = 'User' AND name = 'face_picture';
")
  end
end
