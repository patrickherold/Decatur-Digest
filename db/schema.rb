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

ActiveRecord::Schema.define(:version => 20130930111317) do

  create_table "comments", :force => true do |t|
    t.string   "content"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "lots", :force => true do |t|
    t.string   "tax_district"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.text     "parcel_id"
    t.text     "homestead"
    t.integer  "land_value"
    t.integer  "building_value"
    t.integer  "appraised_value"
    t.integer  "appeal_value"
    t.integer  "taxable"
    t.text     "zoning"
    t.integer  "tax_year"
    t.text     "property_street_sub_number"
    t.integer  "property_street_number"
    t.text     "property_street_name_prefix"
    t.text     "property_street_name"
    t.text     "property_street_type"
    t.text     "property_street_type_postfix"
    t.text     "property_street_suite"
    t.text     "property_city"
    t.text     "property_state"
    t.integer  "property_zip"
    t.integer  "property_zip_plus_four"
    t.text     "owner"
    t.text     "co_owner"
    t.text     "in_care_of"
    t.text     "mailing_street_number"
    t.text     "mailing_street_name_prefix"
    t.text     "mailing_street_name"
    t.text     "mailing_street_type"
    t.text     "mailing_street_type_postfix"
    t.text     "mailing_street_suite"
    t.text     "mailing_city"
    t.text     "mailing_state"
    t.integer  "mailing_zip"
    t.integer  "mailing_zip_plus_four"
    t.float    "latitude"
    t.float    "longitude"
    t.float    "mailing_latitude"
    t.float    "mailing_longitude"
    t.integer  "customer_id"
    t.integer  "municipal_id"
    t.boolean  "gmaps"
  end

  create_table "lots_workflows", :id => false, :force => true do |t|
    t.integer "lot_id"
    t.integer "workflow_id"
  end

  create_table "managers_workflows", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "workflow_id"
  end

  create_table "portfolio", :force => true do |t|
    t.integer  "user_id"
    t.integer  "lot_id"
    t.string   "follow_type"
    t.string   "lot_relationship"
    t.string   "lot_residency"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "portfolios", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "rs_evaluations", :force => true do |t|
    t.string   "reputation_name"
    t.integer  "source_id"
    t.string   "source_type"
    t.integer  "target_id"
    t.string   "target_type"
    t.float    "value",           :default => 0.0
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "rs_evaluations", ["reputation_name", "source_id", "source_type", "target_id", "target_type"], :name => "index_rs_evaluations_on_reputation_name_and_source_and_target", :unique => true
  add_index "rs_evaluations", ["reputation_name"], :name => "index_rs_evaluations_on_reputation_name"
  add_index "rs_evaluations", ["source_id", "source_type"], :name => "index_rs_evaluations_on_source_id_and_source_type"
  add_index "rs_evaluations", ["target_id", "target_type"], :name => "index_rs_evaluations_on_target_id_and_target_type"

  create_table "rs_reputation_messages", :force => true do |t|
    t.integer  "sender_id"
    t.string   "sender_type"
    t.integer  "receiver_id"
    t.float    "weight",      :default => 1.0
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "rs_reputation_messages", ["receiver_id", "sender_id", "sender_type"], :name => "index_rs_reputation_messages_on_receiver_id_and_sender", :unique => true
  add_index "rs_reputation_messages", ["receiver_id"], :name => "index_rs_reputation_messages_on_receiver_id"
  add_index "rs_reputation_messages", ["sender_id", "sender_type"], :name => "index_rs_reputation_messages_on_sender_id_and_sender_type"

  create_table "rs_reputations", :force => true do |t|
    t.string   "reputation_name"
    t.float    "value",           :default => 0.0
    t.string   "aggregated_by"
    t.integer  "target_id"
    t.string   "target_type"
    t.boolean  "active",          :default => true
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "rs_reputations", ["reputation_name", "target_id", "target_type"], :name => "index_rs_reputations_on_reputation_name_and_target", :unique => true
  add_index "rs_reputations", ["reputation_name"], :name => "index_rs_reputations_on_reputation_name"
  add_index "rs_reputations", ["target_id", "target_type"], :name => "index_rs_reputations_on_target_id_and_target_type"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "provider"
    t.string   "uid"
    t.string   "username"
    t.datetime "birthdate"
    t.boolean  "disabled_veteran"
    t.integer  "income"
    t.integer  "income_cents",           :default => 0,     :null => false
    t.string   "income_currency",        :default => "USD", :null => false
    t.string   "fb_name"
    t.string   "fb_first_name"
    t.string   "fb_last_name"
    t.string   "fb_middle_name"
    t.string   "fb_gener"
    t.string   "fb_locale"
    t.string   "fb_link"
    t.string   "fb_username"
    t.string   "fb_timezone"
    t.string   "fb_bio"
    t.string   "fb_birthday"
    t.string   "fb_cover"
    t.string   "fb_email"
    t.string   "fb_users_hometown"
    t.string   "fb_picture"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "workflow_managers_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "manager_id"
  end

  create_table "workflows", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "user_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.text     "status"
  end

end
