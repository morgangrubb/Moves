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

ActiveRecord::Schema.define(:version => 20110117035337) do

  create_table "moves", :force => true do |t|
    t.string   "name",                           :null => false
    t.text     "url",                            :null => false
    t.text     "movie_url"
    t.boolean  "local_movie", :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "moves", ["url"], :name => "index_moves_on_url", :unique => true

  create_table "raw_moves", :force => true do |t|
    t.text     "url"
    t.string   "title"
    t.text     "link_data"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "video_url"
  end

end
