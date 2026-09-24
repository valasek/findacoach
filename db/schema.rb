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

ActiveRecord::Schema[8.1].define(version: 2026_09_21_000001) do
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

  create_table "application_data", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "login_to_demo_count", default: 0, null: false
    t.datetime "updated_at", null: false
  end

  create_table "booking_requests", force: :cascade do |t|
    t.integer "client_id"
    t.text "coach_message"
    t.datetime "created_at", null: false
    t.datetime "decided_at"
    t.integer "duration_minutes", null: false
    t.text "goal", null: false
    t.string "idempotency_key", null: false
    t.integer "session_id"
    t.datetime "starts_at", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.string "visitor_email", null: false
    t.string "visitor_name", null: false
    t.string "visitor_timezone", null: false
    t.index ["client_id"], name: "index_booking_requests_on_client_id"
    t.index ["idempotency_key"], name: "index_booking_requests_on_idempotency_key", unique: true
    t.index ["session_id"], name: "index_booking_requests_on_session_id"
    t.index ["user_id", "status", "starts_at"], name: "index_booking_requests_on_user_id_and_status_and_starts_at"
    t.index ["user_id"], name: "index_booking_requests_on_user_id"
  end

  create_table "booking_settings", force: :cascade do |t|
    t.integer "buffer_minutes", default: 15, null: false
    t.string "calendar_sync_error"
    t.string "calendar_sync_status"
    t.datetime "created_at", null: false
    t.integer "default_duration", default: 60, null: false
    t.json "duration_options", default: [30, 60], null: false
    t.boolean "enabled", default: false, null: false
    t.text "ics_url"
    t.datetime "last_calendar_sync_at"
    t.integer "minimum_notice_hours", default: 24, null: false
    t.string "timezone", default: "UTC", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.json "weekly_hours", default: {}, null: false
    t.index ["user_id"], name: "index_booking_settings_on_user_id", unique: true
  end

  create_table "clients", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "notes"
    t.string "phone"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "email"], name: "index_clients_on_user_id_and_email", unique: true, where: "email IS NOT NULL AND email != ''"
    t.index ["user_id", "phone"], name: "index_clients_on_user_id_and_phone", unique: true, where: "phone IS NOT NULL AND phone != ''"
    t.index ["user_id"], name: "index_clients_on_user_id"
  end

  create_table "services", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "default", default: false, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "name"], name: "index_services_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_services_on_user_id"
    t.index ["user_id"], name: "unique_default_service_per_user", unique: true, where: "\"default\" = true"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "client_id", null: false
    t.datetime "created_at", null: false
    t.date "date"
    t.decimal "duration", precision: 5, scale: 2
    t.boolean "group", default: false
    t.integer "group_size"
    t.text "notes"
    t.boolean "paid", default: true
    t.integer "service_id", null: false
    t.datetime "starts_at"
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_sessions_on_client_id"
    t.index ["service_id"], name: "index_sessions_on_service_id"
    t.index ["starts_at"], name: "index_sessions_on_starts_at"
  end

  create_table "user_profiles", force: :cascade do |t|
    t.text "bio"
    t.datetime "created_at", null: false
    t.string "full_name"
    t.string "phone"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.string "username"
    t.string "website"
    t.index ["user_id"], name: "index_user_profiles_on_user_id"
    t.index ["username"], name: "index_user_profiles_on_username", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.boolean "demo_user", default: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.string "provider"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.string "uid"
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["demo_user"], name: "index_users_on_demo_user"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "booking_requests", "clients"
  add_foreign_key "booking_requests", "sessions"
  add_foreign_key "booking_requests", "users"
  add_foreign_key "booking_settings", "users"
  add_foreign_key "clients", "users"
  add_foreign_key "services", "users"
  add_foreign_key "sessions", "clients"
  add_foreign_key "sessions", "services"
  add_foreign_key "user_profiles", "users"
end
