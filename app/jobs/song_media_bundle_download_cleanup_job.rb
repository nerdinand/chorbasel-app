# frozen_string_literal: true

class SongMediaBundleDownloadCleanupJob < ApplicationJob
  queue_as :default

  def perform
    SongMediaBundleDownload.expired.destroy_all
  end
end
