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

ActiveRecord::Schema[8.1].define(version: 2026_03_01_031639) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "cell_edits", force: :cascade do |t|
    t.text "across_clue_content"
    t.integer "cell_id"
    t.datetime "created_at"
    t.text "down_clue_content"
    t.datetime "updated_at"
    t.index ["cell_id"], name: "index_cell_edits_on_cell_id"
  end

  create_table "cells", force: :cascade do |t|
    t.integer "across_clue_id"
    t.integer "cell_num"
    t.boolean "circled", default: false
    t.integer "col", null: false
    t.integer "crossword_id"
    t.integer "down_clue_id"
    t.integer "index", null: false
    t.boolean "is_across_start", default: false, null: false
    t.boolean "is_down_start", default: false, null: false
    t.boolean "is_void", default: false, null: false
    t.string "letter", limit: 255
    t.integer "row", null: false
    t.index ["across_clue_id"], name: "index_cells_on_across_clue_id"
    t.index ["crossword_id"], name: "index_cells_on_crossword_id"
    t.index ["down_clue_id"], name: "index_cells_on_down_clue_id"
  end

  create_table "clues", force: :cascade do |t|
    t.text "content", default: "ENTER CLUE"
    t.integer "difficulty", default: 1
    t.integer "phrase_id"
    t.integer "user_id"
    t.integer "word_id"
    t.index ["phrase_id"], name: "index_clues_on_phrase_id"
    t.index ["user_id"], name: "index_clues_on_user_id"
    t.index ["word_id"], name: "index_clues_on_word_id"
  end

  create_table "comments", force: :cascade do |t|
    t.integer "base_comment_id"
    t.text "content", null: false
    t.datetime "created_at"
    t.integer "crossword_id"
    t.boolean "flagged", default: false, null: false
    t.datetime "updated_at"
    t.integer "user_id"
    t.index ["base_comment_id"], name: "index_comments_on_base_comment_id"
    t.index ["crossword_id"], name: "index_comments_on_crossword_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "crosswords", force: :cascade do |t|
    t.boolean "circled", default: false
    t.integer "cols", default: 15, null: false
    t.datetime "created_at"
    t.text "description"
    t.text "letters", default: "", null: false
    t.text "preview"
    t.integer "rows", default: 15, null: false
    t.string "title", limit: 255, default: "Untitled", null: false
    t.datetime "updated_at"
    t.integer "user_id"
    t.index ["user_id"], name: "index_crosswords_on_user_id"
  end

  create_table "favorite_puzzles", force: :cascade do |t|
    t.datetime "created_at"
    t.integer "crossword_id", null: false
    t.datetime "updated_at"
    t.integer "user_id", null: false
    t.index ["crossword_id"], name: "index_favorite_puzzles_on_crossword_id"
    t.index ["user_id"], name: "index_favorite_puzzles_on_user_id"
  end

  create_table "friend_requests", id: false, force: :cascade do |t|
    t.string "accompany_message"
    t.datetime "created_at", null: false
    t.integer "recipient_id"
    t.integer "sender_id"
    t.datetime "updated_at", null: false
    t.index ["recipient_id"], name: "index_friend_requests_on_recipient_id"
    t.index ["sender_id"], name: "index_friend_requests_on_sender_id"
  end

  create_table "friendships", id: false, force: :cascade do |t|
    t.integer "friend_id"
    t.integer "user_id"
    t.index ["friend_id"], name: "index_friendships_on_friend_id"
    t.index ["user_id"], name: "index_friendships_on_user_id"
  end

  create_table "phrases", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "solution_partnerings", force: :cascade do |t|
    t.datetime "created_at"
    t.integer "solution_id", null: false
    t.datetime "updated_at"
    t.integer "user_id", null: false
    t.index ["solution_id"], name: "index_solution_partnerings_on_solution_id"
    t.index ["user_id"], name: "index_solution_partnerings_on_user_id"
  end

  create_table "solutions", force: :cascade do |t|
    t.datetime "created_at"
    t.integer "crossword_id"
    t.boolean "is_complete", default: false, null: false
    t.string "key", limit: 255
    t.text "letters", default: "", null: false
    t.datetime "solved_at"
    t.boolean "team", default: false, null: false
    t.datetime "updated_at"
    t.integer "user_id"
    t.index ["crossword_id"], name: "index_solutions_on_crossword_id"
    t.index ["key"], name: "index_solutions_on_key_unique", unique: true, where: "(key IS NOT NULL)"
    t.index ["user_id"], name: "index_solutions_on_user_id"
  end

  create_table "unpublished_crosswords", force: :cascade do |t|
    t.text "across_clues", default: [], array: true
    t.boolean "circle_mode", default: false
    t.text "circles", default: "{}"
    t.integer "cols"
    t.datetime "created_at"
    t.text "description"
    t.text "down_clues", default: [], array: true
    t.text "letters", default: [], array: true
    t.boolean "mirror_voids", default: true
    t.boolean "multiletter_mode", default: false
    t.boolean "one_click_void", default: false
    t.text "potential_words", default: [], array: true
    t.integer "rows"
    t.string "title", default: "Untitled", null: false
    t.datetime "updated_at"
    t.integer "user_id"
    t.index ["user_id"], name: "index_unpublished_crosswords_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "auth_token", limit: 255
    t.datetime "created_at"
    t.string "email", limit: 254, null: false
    t.string "first_name", limit: 18
    t.text "image"
    t.boolean "is_admin", default: false
    t.string "last_name", limit: 24
    t.string "location", limit: 255
    t.string "password_digest", limit: 255
    t.datetime "password_reset_sent_at"
    t.string "password_reset_token", limit: 255
    t.datetime "updated_at"
    t.string "username", limit: 16, null: false
    t.string "verification_token"
    t.boolean "verified", default: false
    t.index ["auth_token"], name: "index_users_on_auth_token", unique: true
  end

  create_table "words", force: :cascade do |t|
    t.string "content", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end
end
