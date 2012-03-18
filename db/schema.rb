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

ActiveRecord::Schema.define(:version => 20120318142620) do

  create_table "documents", :force => true do |t|
    t.integer "entry_id"
    t.integer "language_id"
    t.text    "body"
    t.integer "version_id"
    t.text    "paragraph_id_list"
    t.string  "translated",        :default => "no", :null => false
  end

  create_table "entries", :force => true do |t|
    t.string  "name"
    t.string  "fullname"
    t.string  "type"
    t.integer "superclass_id"
    t.integer "module_id"
    t.integer "library_id"
  end

  create_table "languages", :force => true do |t|
    t.string "english_name"
    t.string "native_name"
    t.string "short_name"
  end

  create_table "paragraphs", :force => true do |t|
    t.text    "body"
    t.integer "language_id"
    t.integer "original_id"
  end

  create_table "versions", :force => true do |t|
    t.string "name"
  end

end
