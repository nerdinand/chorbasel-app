# frozen_string_literal: true

class SongMediaStorageUpdateMailer < ApplicationMailer
  def update_email
    @created_entries = SongMediaStorageEntry.where(identifier: params[:created_entry_identifiers])
    @updated_entries = SongMediaStorageEntry.where(identifier: params[:updated_entry_identifiers])
    @deleted_entry_identifiers = params[:deleted_entry_identifiers]
    @unchanged_entry_identifiers = params[:unchanged_entry_identifiers]

    @orphaned_media = SongMedium.where.not(file_identifier: SongMediaStorageEntry.select(:identifier))

    mail(to: 'app@chorbasel.ch', subject: t('song_media_storage_update_mailer.subject'), from: 'app@chorbasel.ch')
  end
end
