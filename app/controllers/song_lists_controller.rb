# frozen_string_literal: true

class SongListsController < ApplicationController
  def index
    @song_lists = authorize SongList.all
  end

  def show
    @song_list = authorize SongList.includes(:song_list_items).find(params[:id])
  end

  def new
    @song_list = authorize SongList.new
  end

  def edit
    @song_list = authorize SongList.find(params[:id])
  end

  def create
    @song_list = authorize SongList.new(song_list_params)

    if @song_list.save
      flash.notice = t('.success')
      redirect_to song_lists_path
    else
      flash.alert = t('.error')
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @song_list = authorize SongList.find(params[:id])

    if @song_list.update(song_list_params)
      flash.notice = t('.success')
      redirect_to song_lists_path
    else
      flash.alert = t('.error')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    song = authorize SongList.find(params[:id])

    if song.destroy
      flash.notice = t('.success')
      redirect_to song_lists_path
    else
      flash.alert = t('.error')
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def song_list_params
    params.expect(song_list: [:name])
  end
end
