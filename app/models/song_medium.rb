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

  REGISTERS_ORDER = [
    '',
    nil,
    Register::Song::REGISTER_SOLO,
    Register::Song::REGISTER_SOPRANO,
    Register::Song::REGISTER_SOPRANO_1,
    Register::Song::REGISTER_SOPRANO_2,
    Register::Song::REGISTER_MEZZO_SOPRANO,
    Register::Song::REGISTER_ALTO,
    Register::Song::REGISTER_ALTO_1,
    Register::Song::REGISTER_ALTO_2,
    Register::Song::REGISTER_TENOR,
    Register::Song::REGISTER_TENOR_1,
    Register::Song::REGISTER_TENOR_2,
    Register::Song::REGISTER_BARITONE,
    Register::Song::REGISTER_BASS,
    Register::Song::REGISTER_BASS_1,
    Register::Song::REGISTER_BASS_2
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
  scope :ordered_by_register, -> { in_order_of(:register, REGISTERS_ORDER, filter: false) }

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
    return song_media_storage_entry.type_audio? if drive_file_present?

    file.attachment.try(:audio?) || false
  end

  def type_pdf?
    return song_media_storage_entry.type_pdf? if drive_file_present?

    file.attachment.try { |f| f.content_type == 'application/pdf' } || false
  end

  def type_video?
    return song_media_storage_entry.type_video? if drive_file_present?

    file.attachment.try(:video?) || false
  end
end
