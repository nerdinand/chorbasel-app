# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_12_26_143328) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "arask_jobs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "execute_at"
    t.string "interval"
    t.string "job"
    t.datetime "updated_at", null: false
    t.index ["execute_at"], name: "index_arask_jobs_on_execute_at"
  end

  create_table "attendances", force: :cascade do |t|
    t.integer "calendar_event_id", null: false
    t.datetime "created_at", null: false
    t.text "remarks"
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["calendar_event_id", "user_id"], name: "index_attendances_on_calendar_event_id_and_user_id", unique: true
    t.index ["calendar_event_id"], name: "index_attendances_on_calendar_event_id"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "calendar_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.datetime "ends_at", null: false
    t.datetime "event_created_at", null: false
    t.string "location"
    t.datetime "starts_at", null: false
    t.string "summary", null: false
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.index ["starts_at"], name: "index_calendar_events_on_starts_at"
    t.index ["uid"], name: "index_calendar_events_on_uid", unique: true
  end

  create_table "infos", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.string "kind", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "name_guesses", force: :cascade do |t|
    t.boolean "correct", default: false, null: false
    t.datetime "created_at", null: false
    t.integer "guessee_id"
    t.integer "guesser_id"
    t.datetime "updated_at", null: false
    t.index ["guessee_id"], name: "index_name_guesses_on_guessee_id"
    t.index ["guesser_id"], name: "index_name_guesses_on_guesser_id"
  end

  create_table "passwordless_sessions", force: :cascade do |t|
    t.integer "authenticatable_id"
    t.string "authenticatable_type"
    t.datetime "claimed_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "expires_at", precision: nil, null: false
    t.string "identifier", null: false
    t.datetime "timeout_at", precision: nil, null: false
    t.string "token_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["authenticatable_type", "authenticatable_id"], name: "authenticatable"
    t.index ["identifier"], name: "index_passwordless_sessions_on_identifier", unique: true
  end

  create_table "programs", force: :cascade do |t|
    t.integer "calendar_event_id", null: false
    t.datetime "created_at", null: false
    t.integer "song_list_id", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_event_id"], name: "index_programs_on_calendar_event_id"
    t.index ["song_list_id"], name: "index_programs_on_song_list_id"
  end

  create_table "scores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.json "metadata", default: {}, null: false
    t.integer "song_id"
    t.datetime "updated_at", null: false
    t.index ["song_id"], name: "index_scores_on_song_id"
  end

  create_table "song_list_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.text "notes"
    t.integer "position", null: false
    t.integer "song_id"
    t.integer "song_list_id", null: false
    t.datetime "updated_at", null: false
    t.index ["song_id"], name: "index_song_list_items_on_song_id"
    t.index ["song_list_id", "position"], name: "index_song_list_itemss_on_song_list_id_and_position", unique: true
    t.index ["song_list_id"], name: "index_song_list_items_on_song_list_id"
  end

  create_table "song_lists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.string "status"
    t.datetime "updated_at", null: false
  end

  create_table "song_media", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "kind", null: false
    t.string "register"
    t.integer "song_id", null: false
    t.datetime "updated_at", null: false
    t.index ["song_id", "kind", "register"], name: "index_song_media_on_song_id_and_kind_and_register", unique: true
  end

  create_table "song_media_bundle_downloads", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "last_downloaded_at"
    t.text "log"
    t.string "register"
    t.integer "song_list_id"
    t.datetime "song_list_updated_at"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["song_list_id", "register"], name: "index_smbd_on_song_list_id_and_register", unique: true
    t.index ["song_list_id"], name: "index_song_media_bundle_downloads_on_song_list_id"
  end

  create_table "songs", force: :cascade do |t|
    t.string "arranger"
    t.string "composer"
    t.datetime "created_at", null: false
    t.json "genres", default: [], null: false
    t.string "key_signature"
    t.string "language"
    t.text "lyrics"
    t.json "registers", default: [], null: false
    t.boolean "repertoire", default: false, null: false
    t.string "time_signature"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "JSON_TYPE(genres) = 'array'", name: "songs_genres_is_array"
    t.check_constraint "JSON_TYPE(registers) = 'array'", name: "songs_registers_is_array"
  end

  create_table "user_statuses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "from_date"
    t.string "note"
    t.string "status"
    t.date "to_date"
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "users", force: :cascade do |t|
    t.date "birth_date"
    t.string "canonical_register"
    t.string "city"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.string "member_since"
    t.string "nick_name"
    t.string "phone_number"
    t.string "register"
    t.text "remarks"
    t.json "roles", default: [], null: false
    t.string "salutation"
    t.string "street"
    t.datetime "updated_at", null: false
    t.string "zip_code"
    t.index "LOWER(email)", name: "index_users_on_lowercase_email", unique: true
    t.check_constraint "JSON_TYPE(roles) = 'array'", name: "users_roles_is_array"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "attendances", "calendar_events"
  add_foreign_key "attendances", "users"
  add_foreign_key "name_guesses", "users", column: "guessee_id"
  add_foreign_key "name_guesses", "users", column: "guesser_id"
end
