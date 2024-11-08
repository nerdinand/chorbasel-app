# frozen_string_literal: true

class Song < ApplicationRecord
  validates :title, presence: true
  validates :repertoire, inclusion: { in: [true, false] }

  validates :registers, array: Register::Song::REGISTERS
end
