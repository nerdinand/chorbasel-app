# frozen_string_literal: true

class SongMedium < ApplicationRecord
  KIND_SHEET_MUSIC = 'sheet_music'
  KIND_RECORDING_ALL = 'recording_all'
  KIND_RECORDING_REGISTER = 'recording_register'
  KIND_CHOREOGRAPHY_VIDEO = 'choreography_video'

  KINDS = [
    KIND_SHEET_MUSIC,
    KIND_RECORDING_ALL,
    KIND_RECORDING_REGISTER,
    KIND_CHOREOGRAPHY_VIDEO
  ].freeze

  belongs_to :song, touch: true # when a SongMedium changes, its Song changes too
  belongs_to :song_media_storage_entry, foreign_key: :file_identifier, primary_key: :identifier, inverse_of: false,
                                        optional: true
  has_one_attached :file

  validates :register, presence: true, inclusion: Register::Song::REGISTERS, if: proc { |sm|
    sm.kind == KIND_RECORDING_REGISTER
  }
  validates :register, absence: true, if: proc { |sm| sm.kind != KIND_RECORDING_REGISTER }
  validates :kind, presence: true, inclusion: KINDS
  validates :kind, uniqueness: { scope: %i[song_id register] }
  validates :file, presence: true, if: proc { |sm| sm.file_identifier.blank? }
  validates :file_identifier, presence: true, if: proc { |sm| sm.file.blank? }

  scope :recording, -> { where(kind: [KIND_RECORDING_ALL, KIND_RECORDING_REGISTER]) }

  def human_kind
    I18n.t("activerecord.attributes.song_medium.enums.kind.#{kind}")
  end

  def drive_file?
    file_identifier.present?
  end

  def drive_file_present?
    file.blank? && song_media_storage_entry.present?
  end

  def type_audio?
    return song_media_storage_entry.type_audio? if file.drive_file_present?

    file.attachment.try(:audio?) || false
  end

  def type_pdf?
    return song_media_storage_entry.type_pdf? if file.drive_file_present?

    file.attachment.try { |f| f.content_type == 'application/pdf' } || false
  end

  def type_video?
    return song_media_storage_entry.type_video? if file.drive_file_present?

    file.attachment.try(:video?) || false
  end
end
