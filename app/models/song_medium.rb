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

  belongs_to :song
  has_one_attached :file

  validates :register, presence: true, inclusion: Register::Song::REGISTERS, if: proc { |sm|
    sm.kind == KIND_RECORDING_REGISTER
  }
  validates :register, absence: true, if: proc { |sm| sm.kind != KIND_RECORDING_REGISTER }
  validates :kind, presence: true, inclusion: KINDS
  validates :kind, uniqueness: { scope: %i[song_id register] }
  validates :file, presence: true

  scope :recording, -> { where(kind: [KIND_RECORDING_ALL, KIND_RECORDING_REGISTER]) }

  def human_register
    return nil if register.blank?

    I18n.t("activerecord.attributes.song.enums.register.#{register}")
  end

  def human_kind
    I18n.t("activerecord.attributes.song_medium.enums.kind.#{kind}")
  end
end
