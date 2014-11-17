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

ActiveRecord::Schema.define(version: 20141116082449) do

  create_table "admins", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assignments", force: true do |t|
    t.string   "name",        null: false
    t.datetime "due_date"
    t.text     "description"
    t.string   "kind",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "course_id"
    t.integer  "user_id"
  end

  add_index "assignments", ["course_id"], name: "index_assignments_on_course_id"
  add_index "assignments", ["user_id"], name: "index_assignments_on_user_id"

  create_table "comments", force: true do |t|
    t.text     "text",                                    null: false
    t.string   "mark"
    t.binary   "attachment", limit: 10485760
    t.integer  "parent_id",                   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "convenors", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "courses", force: true do |t|
    t.string   "name",        null: false
    t.string   "code",        null: false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "courses_users", id: false, force: true do |t|
    t.integer "course_id"
    t.integer "user_id"
  end

  add_index "courses_users", ["course_id", "user_id"], name: "index_courses_users_on_course_id_and_user_id"
  add_index "courses_users", ["user_id"], name: "index_courses_users_on_user_id"

  create_table "extensions", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "labgroups", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "course_id"
  end

  add_index "labgroups", ["course_id"], name: "index_labgroups_on_course_id"

  create_table "labgroups_users", id: false, force: true do |t|
    t.integer "labgroup_id"
    t.integer "user_id"
  end

  add_index "labgroups_users", ["labgroup_id", "user_id"], name: "index_labgroups_users_on_labgroup_id_and_user_id"
  add_index "labgroups_users", ["user_id"], name: "index_labgroups_users_on_user_id"

  create_table "notifications", force: true do |t|
    t.text     "text"
    t.boolean  "seen"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "students", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "submissions", force: true do |t|
    t.text     "type"
    t.integer  "submitted_by_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "assignment_id"
  end

  add_index "submissions", ["assignment_id"], name: "index_submissions_on_assignment_id"
  add_index "submissions", ["user_id"], name: "index_submissions_on_user_id"

  create_table "tutors", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "uid",                    default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "course_id"
    t.string   "type"
    t.string   "firstname"
    t.string   "surname"
    t.string   "full_name"
    t.boolean  "has_logged_in_once",     default: false
    t.integer  "assignment_id"
  end

  add_index "users", ["assignment_id"], name: "index_users_on_assignment_id"
  add_index "users", ["course_id"], name: "index_users_on_course_id"
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["uid"], name: "index_users_on_uid", unique: true

end
