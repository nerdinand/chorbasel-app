# frozen_string_literal: true

class SongMediaController < ApplicationController
  def new
    @song_medium = authorize SongMedium.new(song_id: params[:song_id])
    @song_media_storage_entries = SongMediaStorageEntry.media_file
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
    song_medium = authorize SongMedium.find(params.expect(:id))

    if song_medium.destroy
      flash.notice = t('.success')
      redirect_to song_path(song_medium.song)
    else
      flash.alert = t('.error')
      render :edit, status: :unprocessable_content
    end
  end

  def load
    storage_entry = authorize(SongMedium.find(params.expect(:song_medium_id))).try(:song_media_storage_entry)
    return render status: :not_found if storage_entry.nil?

    send_data(
      storage_entry.buffer.string.force_encoding('binary'),
      filename: storage_entry.name,
      type: storage_entry.mime_type
    )
  end

  private

  def song_medium_params
    params.expect(song_medium: %i[song_id register kind file file_identifier])
  end
end
