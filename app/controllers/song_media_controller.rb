# frozen_string_literal: true

class SongMediaController < ApplicationController
  def show
    @song_medium = authorize SongMedium.find(params[:id])
  end

  def new
    @song_medium = authorize SongMedium.new(song_id: params[:song_id])
  end

  def create
    @song_medium = authorize SongMedium.new(song_medium_params)

    if @song_medium.save
      flash.notice = t('.success')
      redirect_to song_path(@song_medium.song)
    else
      flash.alert = t('.error')
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    song_medium = authorize SongMedium.find(params[:id])

    if song_medium.destroy
      flash.notice = t('.success')
      redirect_to song_path(song_medium.song)
    else
      flash.alert = t('.error')
      render :edit, status: :unprocessable_content
    end
  end

  private

  def song_medium_params
    params.expect(song_medium: %i[song_id register kind file])
  end
end
