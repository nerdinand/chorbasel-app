# frozen_string_literal: true

module Songs
  class CompletenessesController < ApplicationController
    def show
      songs = authorize Song.includes(:song_media).all
      @song_completenesses = SongCompleteness.build_list(songs)
    end
  end
end
