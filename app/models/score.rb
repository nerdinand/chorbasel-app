# frozen_string_literal: true

class Score < ApplicationRecord
  belongs_to :song

  has_one_attached :file
  validates :segment_markers, presence: true
  validates :measure_markers, presence: true
end
