# frozen_string_literal: true

class SongMediaController < ApplicationController
  def new
    @song_medium = authorize SongMedium.new(song_id: params[:song_id])
  end

  def edit
    @song_medium = authorize SongMedium.find(params[:id])
  end

  def create
    @song_medium = authorize SongMedium.new(song_medium_params)

    if @song_medium.save
      flash[:success] = t('.success')
      redirect_to song_path(@song_medium.song)
    else
      flash[:error] = t('.error')
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @song_medium = authorize SongMedium.find(params[:id])

    if @song_medium.update(song_medium_params)
      flash[:success] = t('.success')
      redirect_to song_path(@song_medium.song)
    else
      flash[:error] = t('.error')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    song_medium = authorize SongMedium.find(params[:id])

    if song_medium.destroy
      flash[:success] = t('.success')
      redirect_to song_path(song_medium.song)
    else
      flash[:error] = t('.error')
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def song_medium_params
    params.require(:song_medium).permit(:song_id, :register, :kind)
  end
end
