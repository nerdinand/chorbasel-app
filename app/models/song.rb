# frozen_string_literal: true

class Song < ApplicationRecord
  has_many :song_media, dependent: :destroy
  has_many :song_list_items, dependent: :nullify
  has_one :score, dependent: :destroy

  validates :title, presence: true
  validates :repertoire, inclusion: { in: [true, false] }

  validates :registers, array: Register::Song::REGISTERS

  normalizes :arranger, :composer, :key_signature, :language, :time_signature, with: ->(str) { str.presence }
end
