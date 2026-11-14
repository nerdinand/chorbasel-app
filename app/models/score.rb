# frozen_string_literal: true

class Score < ApplicationRecord
  belongs_to :song

  has_one_attached :file
  validates :file, presence: true
  validates :metadata, presence: true

  def markers
    parsed_metadata['markers']
  end

  private

  def parsed_metadata
    JSON.parse(metadata)
  end
end
