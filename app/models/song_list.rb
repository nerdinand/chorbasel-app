# frozen_string_literal: true

class SongList < ApplicationRecord
  has_many :song_list_items, dependent: :destroy

  validates :name, presence: true

  enum :status, { in_preparation: 'in_preparation', active: 'active', archived: 'archived' }, default: :in_preparation

  belongs_to :calendar_event, optional: true

  def next_order_number
    (song_list_items.pluck(:order).max || 0) + 1
  end
end
