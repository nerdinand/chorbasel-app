# frozen_string_literal: true

class SongListItem < ApplicationRecord
  belongs_to :song_list, touch: true
  belongs_to :song, optional: true

  positioned on: :song_list

  scope :has_song, -> { where.not(song: nil) }

  def display_name
    return name if name.present?

    song.presence&.title
  end

  def song?
    song.present?
  end
end
