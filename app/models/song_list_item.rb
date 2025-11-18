# frozen_string_literal: true

class SongListItem < ApplicationRecord
  belongs_to :song_list
  belongs_to :song, optional: true

  positioned on: :song_list

  def display_name
    return name if name.present?

    song.title if song.present?
  end

  def song?
    song.present?
  end
end
