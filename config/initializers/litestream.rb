# frozen_string_literal: true

Rails.application.configure do
  config.litestream.replica_bucket = "chorbasel-db-backup-#{Rails.env}"
  config.litestream.replica_key_id = Rails.application.credentials.dig(:hetzner_object_storage, :access_key_id)
  config.litestream.replica_access_key = Rails.application.credentials.dig(:hetzner_object_storage, :secret_access_key)
end
