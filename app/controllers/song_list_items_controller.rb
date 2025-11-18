# frozen_string_literal: true

class SongListItemsController < ApplicationController
  def index
    @song_list_items = policy_scope(SongListItem)
  end

  def show
    @song_list_item = policy_scope(SongListItem).find(params[:id])
  end

  def new
    @song_list_item = authorize SongListItem.new(song_list_id: params[:song_list_id])
  end

  def edit
    @song_list_item = authorize SongListItem.find(params[:id])
  end

  def create
    @song_list_item = authorize SongListItem.new(song_list_item_params)

    if @song_list_item.save
      flash.notice = t('.success')
      redirect_to song_list_path(@song_list_item.song_list)
    else
      flash.alert = t('.error')
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @song_list_item = authorize SongListItem.find(params[:id])

    if @song_list_item.update(song_list_item_params)
      flash.notice = t('.success')
      redirect_to song_list_path(@song_list_item.song_list)
    else
      flash.alert = t('.error')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    song_list_item = authorize SongListItem.find(params[:id])

    if song_list_item.destroy
      flash.notice = t('.success')
      redirect_to song_list_path(song_list_item.song_list)
    else
      flash.alert = t('.error')
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def song_list_item_params
    params.expect(song_list_item: %i[name notes song_list_id song_id position])
  end
end
