# frozen_string_literal: true

class SongList < ApplicationRecord
  has_many :song_list_items, dependent: :destroy

  validates :name, presence: true

  enum :status, { in_preparation: 'in_preparation', active: 'active', archived: 'archived' }, default: :in_preparation

  has_many :programs, dependent: :destroy
  has_many :calendar_events, through: :programs

  def next_order_number
    (song_list_items.pluck(:order).max || 0) + 1
  end
end
