# frozen_string_literal: true

class LyricsController < ApplicationController
  def show
    @song_list = SongList.find(params.expect(:song_list_id))
  end
end
