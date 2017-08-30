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

ActiveRecord::Schema.define(version: 20170830070539) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assignment_extensions", force: :cascade do |t|
    t.datetime "due_date"
    t.integer  "assignment_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assignments", force: :cascade do |t|
    t.string   "name",                                null: false
    t.datetime "due_date"
    t.text     "description"
    t.text     "tests"
    t.string   "kind",                                null: false
    t.integer  "course_id"
    t.integer  "user_id"
    t.boolean  "peer_review_enabled"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "copy_path"
    t.boolean  "disable_compilation", default: false
    t.string   "lang"
    t.string   "pdf_regex"
    t.string   "zip_regex"
    t.string   "custom_command"
    t.boolean  "custom_compilation",  default: false
    t.integer  "timeout",             default: 3
  end

  create_table "assignments_users", force: :cascade do |t|
    t.integer "user_id"
    t.integer "assignment_id"
    t.index ["assignment_id", "user_id"], name: "index_assignments_users_on_assignment_id_and_user_id", using: :btree
    t.index ["user_id"], name: "index_assignments_users_on_user_id", using: :btree
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "submission_id"
    t.integer  "user_id"
    t.text     "text",                          null: false
    t.string   "mark"
    t.integer  "parent_id",     default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment"
    t.boolean  "hidden",        default: false
    t.boolean  "visible",       default: true
  end

  create_table "convenors", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "course_roles", force: :cascade do |t|
    t.integer  "course_id",  null: false
    t.integer  "user_id",    null: false
    t.string   "role",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "courses", force: :cascade do |t|
    t.string   "name",        null: false
    t.string   "code",        null: false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "courses_users", force: :cascade do |t|
    t.integer "course_id"
    t.integer "user_id"
    t.integer "convenor_id"
    t.integer "student_id"
    t.index ["convenor_id"], name: "index_courses_users_on_convenor_id", using: :btree
    t.index ["course_id", "convenor_id"], name: "index_courses_users_on_course_id_and_convenor_id", using: :btree
    t.index ["course_id", "student_id"], name: "index_courses_users_on_course_id_and_student_id", using: :btree
    t.index ["course_id", "user_id"], name: "index_courses_users_on_course_id_and_user_id", using: :btree
    t.index ["student_id"], name: "index_courses_users_on_student_id", using: :btree
    t.index ["user_id"], name: "index_courses_users_on_user_id", using: :btree
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "errors", force: :cascade do |t|
    t.string   "usable_type"
    t.integer  "usable_id"
    t.text     "class_name"
    t.text     "message"
    t.text     "trace"
    t.text     "target_url"
    t.text     "referer_url"
    t.text     "params"
    t.text     "user_agent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "extensions", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_roles", force: :cascade do |t|
    t.integer  "group_id",   null: false
    t.integer  "user_id",    null: false
    t.string   "role",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name",       null: false
    t.integer  "course_id"
    t.integer  "tutor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "groups_users", force: :cascade do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.integer "student_id"
    t.integer "convenor_id"
    t.integer "tutor_id"
    t.index ["convenor_id"], name: "index_groups_users_on_convenor_id", using: :btree
    t.index ["group_id", "convenor_id"], name: "index_groups_users_on_group_id_and_convenor_id", using: :btree
    t.index ["group_id", "student_id"], name: "index_groups_users_on_group_id_and_student_id", using: :btree
    t.index ["group_id", "tutor_id"], name: "index_groups_users_on_group_id_and_tutor_id", using: :btree
    t.index ["group_id", "user_id"], name: "index_groups_users_on_group_id_and_user_id", using: :btree
    t.index ["student_id"], name: "index_groups_users_on_student_id", using: :btree
    t.index ["tutor_id"], name: "index_groups_users_on_tutor_id", using: :btree
    t.index ["user_id"], name: "index_groups_users_on_user_id", using: :btree
  end

  create_table "notifications", force: :cascade do |t|
    t.text     "text"
    t.string   "link"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
    t.index ["updated_at"], name: "index_sessions_on_updated_at", using: :btree
  end

  create_table "students", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "submissions", force: :cascade do |t|
    t.text     "kind"
    t.text     "plaintext"
    t.integer  "user_id"
    t.integer  "assignment_id"
    t.boolean  "finalised",           default: false
    t.integer  "peer_review_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "test_results", force: :cascade do |t|
    t.integer  "submission_id"
    t.text     "result"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tutors", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
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
    t.integer  "group_id"
    t.integer  "course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.string   "firstname"
    t.string   "surname"
    t.string   "full_name"
    t.boolean  "has_logged_in_once",     default: false
    t.integer  "assignment_id"
    t.text     "role"
    t.boolean  "convenor",               default: false, null: false
    t.boolean  "admin",                  default: false, null: false
    t.index ["assignment_id"], name: "index_users_on_assignment_id", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["uid"], name: "index_users_on_uid", unique: true, using: :btree
  end

end
