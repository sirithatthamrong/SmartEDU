# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_03_30_050536) do
  create_table "attendances", force: :cascade do |t|
    t.integer "student_id", null: false
    t.datetime "timestamp"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id"], name: "index_attendances_on_student_id"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "classrooms", force: :cascade do |t|
    t.string "class_id", null: false
    t.integer "grade_level", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "school_id"
    t.index ["school_id", "class_id"], name: "index_classrooms_on_school_id_and_class_id", unique: true
  end

  create_table "color_themes", force: :cascade do |t|
    t.integer "school_id", null: false
    t.string "theme_name", null: false
    t.string "primary_color"
    t.string "primary_content_color"
    t.string "secondary_color"
    t.string "secondary_content_color"
    t.string "accent_color"
    t.string "accent_content_color"
    t.string "base_100_color"
    t.string "base_200_color"
    t.string "base_300_color"
    t.string "base_500_color"
    t.string "base_content_color"
    t.string "neutral_color"
    t.string "neutral_content_color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_color_themes_on_school_id"
  end

  create_table "homerooms", force: :cascade do |t|
    t.integer "teacher_id", null: false
    t.integer "classroom_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["classroom_id"], name: "index_homerooms_on_classroom_id"
    t.index ["teacher_id"], name: "index_homerooms_on_teacher_id"
  end

  create_table "payments", force: :cascade do |t|
    t.integer "amount", null: false
    t.string "status", default: "pending", null: false
    t.string "stripe_payment_intent_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.datetime "subscription_start"
    t.datetime "subscription_end"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "principal_teacher_relationships", force: :cascade do |t|
    t.integer "principal_id", null: false
    t.integer "teacher_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["principal_id"], name: "index_principal_teacher_relationships_on_principal_id"
    t.index ["teacher_id"], name: "index_principal_teacher_relationships_on_teacher_id"
  end

  create_table "school_tiers", force: :cascade do |t|
    t.integer "school_id", null: false
    t.string "tier", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_school_tiers_on_school_id"
  end

  create_table "schools", force: :cascade do |t|
    t.string "name", null: false
    t.string "address", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "has_paid"
    t.integer "tier", default: 1
    t.datetime "subscription_end"
    t.index ["name"], name: "index_schools_on_name", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "students", force: :cascade do |t|
    t.string "name"
    t.string "uid", null: false
    t.datetime "discarded_at"
    t.boolean "is_active", default: true, null: false
    t.integer "grade"
    t.string "student_email_address", default: "student@example.com", null: false
    t.string "parent_email_address", default: "parent@example.com", null: false
    t.integer "classroom_id", null: false
    t.index ["classroom_id"], name: "index_students_on_classroom_id"
    t.index ["discarded_at"], name: "index_students_on_discarded_at"
  end

  create_table "teacher_student_relationships", force: :cascade do |t|
    t.integer "teacher_id", null: false
    t.integer "student_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id"], name: "index_teacher_student_relationships_on_student_id"
    t.index ["teacher_id"], name: "index_teacher_student_relationships_on_teacher_id"
  end

  add_foreign_key "Users", "schools"
  add_foreign_key "attendances", "students"
  add_foreign_key "attendances", "users"
  add_foreign_key "color_themes", "schools"
  add_foreign_key "homerooms", "classrooms"
  add_foreign_key "homerooms", "users", column: "teacher_id"
  add_foreign_key "payments", "users"
  add_foreign_key "principal_teacher_relationships", "users", column: "principal_id"
  add_foreign_key "principal_teacher_relationships", "users", column: "teacher_id"
  add_foreign_key "school_tiers", "schools"
  add_foreign_key "sessions", "users"
  add_foreign_key "students", "classrooms"
  add_foreign_key "students", "users", column: "student_email_address", primary_key: "email_address"
  add_foreign_key "students", "users", column: "student_email_address", primary_key: "email_address"
  add_foreign_key "teacher_student_relationships", "users", column: "student_id"
  add_foreign_key "teacher_student_relationships", "users", column: "teacher_id"
  add_foreign_key "users", "schools"
end
