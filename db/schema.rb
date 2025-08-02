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

ActiveRecord::Schema[8.0].define(version: 2025_08_01_234947) do
  create_table "tasks", force: :cascade do |t|
    t.boolean "status_task", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "do_day"
    t.string "task"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "completed_at"
    t.index ["completed_at"], name: "index_tasks_on_completed_at"
    t.index ["end_date"], name: "index_tasks_on_end_date"
    t.index ["start_date", "end_date"], name: "index_tasks_on_start_date_and_end_date"
    t.index ["start_date"], name: "index_tasks_on_start_date"
    t.index ["status_task"], name: "index_tasks_on_status_task"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "img"
    t.boolean "objective"
    t.boolean "complated_day_task"
    t.boolean "create_day_task"
    t.boolean "complated_objective"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
