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

ActiveRecord::Schema[8.1].define(version: 2026_06_08_193035) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "cards", force: :cascade do |t|
    t.text "back_text"
    t.bigint "collection_id", null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.text "front_text"
    t.bigint "source_language_id", null: false
    t.bigint "target_language_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["collection_id"], name: "index_cards_on_collection_id"
    t.index ["deleted_at"], name: "index_cards_on_deleted_at"
    t.index ["source_language_id"], name: "index_cards_on_source_language_id"
    t.index ["target_language_id"], name: "index_cards_on_target_language_id"
    t.index ["user_id"], name: "index_cards_on_user_id"
  end

  create_table "collections", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.bigint "language_id", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["language_id"], name: "index_collections_on_language_id"
    t.index ["user_id"], name: "index_collections_on_user_id"
  end

  create_table "languages", force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.string "name"
    t.string "native_name"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.bigint "native_language_id"
    t.bigint "preferred_language_id"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["native_language_id"], name: "index_users_on_native_language_id"
    t.index ["preferred_language_id"], name: "index_users_on_preferred_language_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "cards", "collections"
  add_foreign_key "cards", "languages", column: "source_language_id"
  add_foreign_key "cards", "languages", column: "target_language_id"
  add_foreign_key "cards", "users"
  add_foreign_key "collections", "languages"
  add_foreign_key "collections", "users"
  add_foreign_key "users", "languages", column: "native_language_id"
  add_foreign_key "users", "languages", column: "preferred_language_id"
end
