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

ActiveRecord::Schema.define(version: 20170816085454) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "annotations", force: :cascade do |t|
    t.text "text"
  end

  create_table "assignments", force: :cascade do |t|
    t.integer "member_id",                  null: false
    t.integer "mandate_id",                 null: false
    t.boolean "approved",   default: false
    t.index ["mandate_id", "member_id"], name: "index_assignments_on_mandate_id_and_member_id", unique: true, using: :btree
    t.index ["member_id", "mandate_id"], name: "index_assignments_on_member_id_and_mandate_id", unique: true, using: :btree
  end

  create_table "attendances", force: :cascade do |t|
    t.integer "event_id"
    t.integer "member_id"
    t.boolean "permitted"
    t.boolean "passed"
  end

  create_table "bibliographies", force: :cascade do |t|
    t.string  "title"
    t.integer "department_id"
    t.text    "description"
  end

  create_table "conversation_views", force: :cascade do |t|
    t.integer  "conversation_id"
    t.integer  "member_id"
    t.datetime "viewed_at"
    t.index ["conversation_id"], name: "index_conversation_views_on_conversation_id", using: :btree
    t.index ["member_id"], name: "index_conversation_views_on_member_id", using: :btree
  end

  create_table "conversations", force: :cascade do |t|
    t.boolean  "private"
    t.integer  "member1_id"
    t.integer  "member2_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "mandate_id"
    t.integer  "event_id"
    t.integer  "project_id"
    t.index ["project_id"], name: "index_conversations_on_project_id", using: :btree
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

  create_table "documents", force: :cascade do |t|
    t.string   "title"
    t.text     "tags"
    t.text     "comment"
    t.integer  "member_id"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "bibliography_id"
    t.index ["bibliography_id"], name: "index_documents_on_bibliography_id", using: :btree
    t.index ["member_id"], name: "index_documents_on_member_id", using: :btree
  end

  create_table "events", force: :cascade do |t|
    t.string   "title"
    t.string   "where"
    t.string   "type"
    t.integer  "limit"
    t.string   "module"
    t.boolean  "permission_required"
    t.boolean  "archive"
    t.text     "description"
    t.integer  "department_id"
    t.date     "qualification_date"
    t.datetime "dates",               default: [], array: true
  end

  create_table "fee_payments", force: :cascade do |t|
    t.text    "payment_history_notes"
    t.boolean "paid"
    t.boolean "direct_debit_allowed"
    t.text    "account_details"
    t.integer "member_id"
  end

  create_table "inquiries", force: :cascade do |t|
    t.integer  "member_id"
    t.boolean  "simple"
    t.string   "title"
    t.boolean  "done"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "client_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.integer  "member_id"
    t.integer  "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_invitations_on_member_id", using: :btree
    t.index ["project_id"], name: "index_invitations_on_project_id", using: :btree
  end

  create_table "mandates", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "client_id"
    t.string   "status",                  default: "vacant", null: false
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.string   "code"
    t.boolean  "supervised",              default: false,    null: false
  end

  create_table "members", force: :cascade do |t|
    t.string   "email",                      default: "",    null: false
    t.string   "encrypted_password",         default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",              default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "first_name"
    t.string   "last_name"
    t.date     "entry_date"
    t.integer  "departments",                default: [],                 array: true
    t.string   "languages"
    t.boolean  "available",                  default: true
    t.string   "course_of_studies"
    t.string   "semester_count"
    t.string   "hobbies"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.text     "public_infos"
    t.string   "phone"
    t.integer  "failed_attempts",            default: 0
    t.datetime "locked_at"
    t.boolean  "did_confirm_privacy_clause", default: false
    t.integer  "annotation_id"
    t.index ["email"], name: "index_members_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_members_on_reset_password_token", unique: true, using: :btree
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "conversation_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.text     "text"
    t.integer  "member_id"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.integer  "children_count",          default: 0
    t.integer  "parent_id"
  end

  create_table "people", force: :cascade do |t|
    t.string  "role"
    t.string  "email"
    t.string  "phone"
    t.string  "languages"
    t.integer "department_id"
    t.string  "first_name"
    t.string  "last_name"
    t.boolean "public",        default: false
    t.text    "comment"
  end

  create_table "projects", force: :cascade do |t|
    t.string   "title"
    t.integer  "departments",       default: [],                 array: true
    t.boolean  "archived",          default: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.text     "description"
    t.boolean  "use_for_infoboard", default: false
  end

  create_table "tasks", force: :cascade do |t|
    t.string   "title"
    t.integer  "mandate_id"
    t.integer  "member_id"
    t.date     "deadline"
    t.boolean  "done",               default: false
    t.integer  "assigned_member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "department_id"
  end

  add_foreign_key "conversation_views", "conversations"
  add_foreign_key "conversation_views", "members"
  add_foreign_key "conversations", "projects"
  add_foreign_key "documents", "bibliographies"
end
