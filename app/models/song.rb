# frozen_string_literal: true

class Song < ApplicationRecord
  has_many :song_media, dependent: :destroy

  validates :title, presence: true
  validates :repertoire, inclusion: { in: [true, false] }

  validates :registers, array: Register::Song::REGISTERS
end
