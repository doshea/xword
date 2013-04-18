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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130418051050) do

  create_table "clue_instances", :force => true do |t|
    t.integer  "start_cell"
    t.boolean  "is_across"
    t.integer  "clue_id"
    t.integer  "crossword_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "clues", :force => true do |t|
    t.text     "content"
    t.integer  "difficulty"
    t.integer  "user_id"
    t.integer  "word_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "comments", :force => true do |t|
    t.text     "content"
    t.boolean  "flagged",      :default => false
    t.integer  "user_id"
    t.integer  "crossword_id"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "crosswords", :force => true do |t|
    t.string   "title",          :default => "Untitled", :null => false
    t.boolean  "published",      :default => false
    t.datetime "date_published"
    t.text     "description"
    t.integer  "rows",           :default => 15,         :null => false
    t.integer  "cols",           :default => 15,         :null => false
    t.text     "letters",        :default => "",         :null => false
    t.text     "gridnums",       :default => "",         :null => false
    t.text     "circles"
    t.integer  "user_id"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  create_table "crosswords_words", :id => false, :force => true do |t|
    t.integer "crossword_id"
    t.integer "word_id"
  end

  create_table "solutions", :force => true do |t|
    t.text     "letters",      :default => "",    :null => false
    t.boolean  "is_complete",  :default => false, :null => false
    t.integer  "user_id"
    t.integer  "crossword_id"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "username",                           :null => false
    t.string   "email",                              :null => false
    t.boolean  "is_admin",        :default => false
    t.string   "password_digest"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.text     "image"
    t.string   "location"
    t.string   "auth_token"
  end

  create_table "words", :force => true do |t|
    t.string   "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
