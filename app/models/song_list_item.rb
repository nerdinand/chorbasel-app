# frozen_string_literal: true

class SongListItem < ApplicationRecord
  belongs_to :song_list
  belongs_to :song, optional: true

  validates :order, numericality: { only_integer: true }

  before_save :set_name

  def set_name
    return if name.present?
    return if song.blank?

    self.name = song.title
  end
end
