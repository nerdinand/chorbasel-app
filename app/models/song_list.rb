# frozen_string_literal: true

class SongList < ApplicationRecord
  has_many :song_list_items, dependent: :destroy

  belongs_to :calendar_event, optional: true
end
