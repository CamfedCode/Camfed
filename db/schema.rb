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

ActiveRecord::Schema.define(:version => 20130114124504) do

  create_table "add_default_value_to_field_mapppings", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "configurations", :force => true do |t|
    t.string   "epi_surveyor_url"
    t.string   "epi_surveyor_user"
    t.string   "epi_surveyor_token"
    t.string   "salesforce_url"
    t.string   "salesforce_user"
    t.string   "salesforce_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "salesforce_browse_url"
    t.string   "supported_languages",   :default => "Swahili"
  end

  create_table "field_mappings", :force => true do |t|
    t.integer  "object_mapping_id"
    t.string   "field_name"
    t.string   "question_name"
    t.string   "lookup_object_name"
    t.string   "lookup_condition"
    t.string   "predefined_value"
    t.string   "lookup_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "import_histories", :force => true do |t|
    t.integer  "survey_id"
    t.string   "survey_response_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "object_histories", :force => true do |t|
    t.integer  "import_history_id"
    t.string   "salesforce_id"
    t.string   "salesforce_object"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "object_mappings", :force => true do |t|
    t.integer  "survey_id"
    t.string   "salesforce_object_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "salesforce_objects", :force => true do |t|
    t.string   "name"
    t.string   "label"
    t.boolean  "enabled"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "surveys", :force => true do |t|
    t.string   "name"
    t.datetime "last_imported_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "notification_email"
    t.datetime "mapping_last_modified_at"
    t.string   "mapping_status",           :default => ""
  end

  create_table "sync_errors", :force => true do |t|
    t.integer  "import_history_id"
    t.string   "salesforce_object"
    t.text     "raw_request",       :limit => 255
    t.text     "raw_response",      :limit => 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "",    :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "",    :null => false
    t.string   "password_salt",                       :default => "",    :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                               :default => false
    t.boolean  "verified_by_admin"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
