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

ActiveRecord::Schema.define(:version => 20110210232202) do

  create_table "field_mappings", :force => true do |t|
    t.integer "object_mapping_id"
    t.string  "field_name"
    t.string  "question_name"
  end

  create_table "import_histories", :force => true do |t|
    t.integer  "survey_id",          :limit => 255
    t.string   "survey_name"
    t.string   "survey_response_id"
    t.text     "error_message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "object_mappings", :force => true do |t|
    t.integer "survey_id"
    t.string  "sf_object_type"
  end

  create_table "surveys", :force => true do |t|
    t.string   "name"
    t.datetime "last_imported_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
