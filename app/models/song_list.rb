# frozen_string_literal: true

class SongList < ApplicationRecord
  has_many :song_list_items, dependent: :destroy
  has_many :song_media_bundle_downloads, dependent: :destroy

  validates :name, presence: true

  enum :status, { in_preparation: 'in_preparation', active: 'active', archived: 'archived' }, default: :in_preparation

  has_many :programs, dependent: :destroy
  has_many :calendar_events, through: :programs

  def next_order_number
    (song_list_items.pluck(:order).max || 0) + 1
  end

  def last_updated_at
    return updated_at if song_list_items.none?

    song_list_items.pluck(:updated_at).union(song_list_items.joins(:song).pluck('songs.updated_at')).max
  end
end
