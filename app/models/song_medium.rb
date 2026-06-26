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

  def type_audio?
    return false if file.blank?

    file.attachment.audio?
  end

  def type_pdf?
    return false if file.blank?

    file.attachment.content_type == 'application/pdf'
  end

  def type_video?
    return false if file.blank?

    file.attachment.video?
  end
end
