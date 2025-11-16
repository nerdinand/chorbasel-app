# frozen_string_literal: true

module SongListItemsHelper
  def song_list_item_song_options
    Song.all.map { |s| [s.title, s.id] }
  end

  def song_list_item_icon(song_list_item)
    if song_list_item.song.present?
      tabler_icon(:music, classes: ['status-icon'])
    else
      empty_icon
    end
  end
end
