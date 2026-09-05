# frozen_string_literal: true

class SongMediaStorageEntry < ApplicationRecord
  validates :identifier, :name, :mime_type, presence: true

  belongs_to :parent, class_name: 'SongMediaStorageEntry', foreign_key: :parent_identifier, primary_key: :identifier,
                      inverse_of: :children, optional: true
  has_many :children, class_name: 'SongMediaStorageEntry', dependent: nil

  scope :media_file, -> { video.or(audio).or(pdf) }
  scope :video, -> { where("mime_type like 'video/%'") }
  scope :audio, -> { where("mime_type like 'audio/%' or mime_type = 'application/ogg'") }
  scope :pdf, -> { where("mime_type = 'application/pdf'") }
end
