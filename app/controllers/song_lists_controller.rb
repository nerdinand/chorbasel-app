# frozen_string_literal: true

class SongListsController < ApplicationController
  def index
    @song_lists = policy_scope(SongList)
  end

  def show
    @song_list = policy_scope(SongList).includes(:song_list_items).find(params[:id])
  end

  def new
    @song_list = authorize SongList.new
  end

  def edit
    @song_list = authorize SongList.find(params[:id])
    @program = authorize Program.new(song_list: @song_list)
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
    song_list = authorize SongList.find(params[:id])

    if song_list.destroy
      flash.notice = t('.success')
      redirect_to song_lists_path
    else
      flash.alert = t('.error')
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def song_list_params
    params.expect(song_list: %i[name status calendar_event_id])
  end
end
