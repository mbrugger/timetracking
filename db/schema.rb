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

ActiveRecord::Schema.define(version: 20150427175117) do

  create_table "employments", force: true do |t|
    t.date     "startDate"
    t.date     "endDate"
    t.float    "weeklyHours",           limit: 24
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "leave_days"
    t.integer  "working_hours_balance"
    t.boolean  "migrated_employment"
  end

  add_index "employments", ["user_id"], name: "index_employments_on_user_id", using: :btree

  create_table "leave_days", force: true do |t|
    t.date     "date"
    t.string   "description"
    t.string   "leave_day_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "leave_days", ["date", "user_id"], name: "index_leave_days_on_date_and_user_id", unique: true, using: :btree
  add_index "leave_days", ["user_id"], name: "index_leave_days_on_user_id", using: :btree

  create_table "public_holidays", force: true do |t|
    t.string   "name"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "public_holidays", ["date"], name: "index_public_holidays_on_date", unique: true, using: :btree

  create_table "reports", force: true do |t|
    t.date     "date"
    t.integer  "balance"
    t.integer  "workingHours"
    t.integer  "correction"
    t.string   "correctionReason"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "leave_days"
  end

  add_index "reports", ["date", "user_id"], name: "index_reports_on_date_and_user_id", unique: true, using: :btree
  add_index "reports", ["user_id"], name: "index_reports_on_user_id", using: :btree

  create_table "time_entries", force: true do |t|
    t.date     "date"
    t.datetime "startTime"
    t.datetime "stopTime"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "time_entries", ["user_id"], name: "index_time_entries_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",   null: false
    t.string   "encrypted_password",     default: "",   null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
    t.string   "time_zone"
    t.string   "name"
    t.string   "token"
    t.boolean  "validate_working_days",  default: true
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["token"], name: "index_users_on_token", using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
