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

ActiveRecord::Schema[8.0].define(version: 2024_10_18_140112) do
  create_table "arask_jobs", force: :cascade do |t|
    t.string "job"
    t.datetime "execute_at"
    t.string "interval"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["execute_at"], name: "index_arask_jobs_on_execute_at"
  end

  create_table "attendances", force: :cascade do |t|
    t.string "status", null: false
    t.integer "calendar_event_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_event_id", "user_id"], name: "index_attendances_on_calendar_event_id_and_user_id", unique: true
    t.index ["calendar_event_id"], name: "index_attendances_on_calendar_event_id"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "calendar_events", force: :cascade do |t|
    t.string "uid", null: false
    t.datetime "event_created_at", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.string "location"
    t.string "summary", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["starts_at"], name: "index_calendar_events_on_starts_at"
    t.index ["uid"], name: "index_calendar_events_on_uid", unique: true
  end

  create_table "passwordless_sessions", force: :cascade do |t|
    t.string "authenticatable_type"
    t.integer "authenticatable_id"
    t.datetime "timeout_at", precision: nil, null: false
    t.datetime "expires_at", precision: nil, null: false
    t.datetime "claimed_at", precision: nil
    t.string "token_digest", null: false
    t.string "identifier", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authenticatable_type", "authenticatable_id"], name: "authenticatable"
    t.index ["identifier"], name: "index_passwordless_sessions_on_identifier", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "roles", default: [], null: false
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.string "nick_name"
    t.index "LOWER(email)", name: "index_users_on_lowercase_email", unique: true
    t.check_constraint "JSON_TYPE(roles) = 'array'", name: "users_roles_is_array"
  end

  add_foreign_key "attendances", "calendar_events"
  add_foreign_key "attendances", "users"
end
