# frozen_string_literal: true

class SongMediaBundleDownloadsController < ApplicationController
  def show
    @song_media_bundle_download = authorize SongMediaBundleDownload.find(params[:id])
  end

  def create
    song_media_bundle_download = authorize SongMediaBundleDownload.find_or_create_by(
      song_list_id: params[:song_list_id],
      canonical_register: current_user.canonical_register
    )

    song_media_bundle_download.regenerate_if_necessary!

    redirect_to [song_media_bundle_download.song_list, song_media_bundle_download]
  end
end
