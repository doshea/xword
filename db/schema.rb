# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160111070656) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cell_edits", force: :cascade do |t|
    t.text     "across_clue_content"
    t.text     "down_clue_content"
    t.integer  "cell_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cells", force: :cascade do |t|
    t.string  "letter",          limit: 255
    t.integer "row",                                         null: false
    t.integer "col",                                         null: false
    t.integer "index",                                       null: false
    t.integer "cell_num"
    t.boolean "is_void",                     default: false, null: false
    t.boolean "is_across_start",             default: false, null: false
    t.boolean "is_down_start",               default: false, null: false
    t.integer "crossword_id"
    t.integer "across_clue_id"
    t.integer "down_clue_id"
    t.boolean "circled",                     default: false
  end

  create_table "clues", force: :cascade do |t|
    t.text    "content",    default: "ENTER CLUE"
    t.integer "difficulty", default: 1
    t.integer "user_id"
    t.integer "word_id"
    t.integer "phrase_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text     "content",                         null: false
    t.boolean  "flagged",         default: false, null: false
    t.integer  "user_id"
    t.integer  "crossword_id"
    t.integer  "base_comment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "crosswords", force: :cascade do |t|
    t.string   "title",       limit: 255, default: "Untitled", null: false
    t.text     "letters",                 default: "",         null: false
    t.text     "description"
    t.integer  "rows",                    default: 15,         null: false
    t.integer  "cols",                    default: 15,         null: false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "circled",                 default: false
    t.text     "preview"
  end

  create_table "favorite_puzzles", force: :cascade do |t|
    t.integer  "crossword_id", null: false
    t.integer  "user_id",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "phrases", force: :cascade do |t|
    t.text     "content",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "solution_partnerings", force: :cascade do |t|
    t.integer  "user_id",     null: false
    t.integer  "solution_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "solutions", force: :cascade do |t|
    t.text     "letters",                  default: "",    null: false
    t.boolean  "is_complete",              default: false, null: false
    t.integer  "user_id"
    t.integer  "crossword_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "team",                     default: false, null: false
    t.string   "key",          limit: 255
    t.datetime "solved_at"
    t.text     "partner_ids",              default: [],                 array: true
  end

  create_table "unpublished_crosswords", force: :cascade do |t|
    t.string   "title",            default: "Untitled", null: false
    t.text     "letters",          default: [],                      array: true
    t.text     "description"
    t.integer  "rows"
    t.integer  "cols"
    t.integer  "user_id"
    t.text     "circles",          default: "{}"
    t.text     "potential_words",  default: [],                      array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "across_clues",     default: [],                      array: true
    t.text     "down_clues",       default: [],                      array: true
    t.boolean  "mirror_voids",     default: true
    t.boolean  "circle_mode",      default: false
    t.boolean  "one_click_void",   default: false
    t.boolean  "multiletter_mode", default: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name",             limit: 18
    t.string   "last_name",              limit: 24
    t.string   "username",               limit: 16,                  null: false
    t.string   "email",                  limit: 254,                 null: false
    t.text     "image"
    t.string   "location",               limit: 255
    t.boolean  "is_admin",                           default: false
    t.string   "password_digest",        limit: 255
    t.string   "auth_token",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_reset_token",   limit: 255
    t.datetime "password_reset_sent_at"
    t.boolean  "verified",                           default: false
    t.string   "verification_token"
  end

  create_table "words", force: :cascade do |t|
    t.string   "content",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
