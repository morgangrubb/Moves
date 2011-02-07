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

ActiveRecord::Schema.define(:version => 20110206232608) do

  create_table "attributes", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attributes", ["type"], :name => "index_attributes_on_type"

  create_table "move_beats", :force => true do |t|
    t.integer  "move_id",     :null => false
    t.string   "beat"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "move_beats", ["move_id"], :name => "index_move_beats_on_move_id"

  create_table "move_variants", :force => true do |t|
    t.integer  "base_id"
    t.integer  "variant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "moves", :force => true do |t|
    t.string   "name",                                     :null => false
    t.text     "url",                                      :null => false
    t.text     "movie_url"
    t.boolean  "local_movie",           :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lead_start_hand_id"
    t.integer  "lead_finish_hand_id"
    t.integer  "follow_start_hand_id"
    t.integer  "follow_finish_hand_id"
    t.boolean  "spins"
    t.integer  "beats"
    t.integer  "category_id"
    t.integer  "difficulty_id"
    t.text     "variant_keys"
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
