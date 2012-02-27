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

ActiveRecord::Schema.define(:version => 20120227051210) do

  create_table "documents", :force => true do |t|
    t.integer "entry_id"
    t.integer "language_id"
    t.text    "body"
  end

  create_table "entries", :force => true do |t|
    t.string  "name"
    t.string  "fullname"
    t.integer "superclass_id"
    t.string  "kind"
  end

  create_table "entry_types", :force => true do |t|
    t.string "name"
  end

  create_table "languages", :force => true do |t|
    t.string "english_name"
    t.string "native_name"
    t.string "short_name"
  end

end
