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

ActiveRecord::Schema[7.0].define(version: 2022_05_20_004620) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "entries", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "kind"
    t.integer "value_cents", default: 0, null: false
    t.string "value_currency", default: "BRL", null: false
    t.integer "payment_method"
    t.integer "category"
    t.string "origin"
    t.integer "installment_number"
    t.integer "installment_total"
    t.datetime "paid_at"
    t.integer "day_of_month_to_pay"
    t.bigint "entry_id"
    t.bigint "month_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "periodic_entry_id"
    t.index ["entry_id"], name: "index_entries_on_entry_id"
    t.index ["month_id"], name: "index_entries_on_month_id"
    t.index ["periodic_entry_id"], name: "index_entries_on_periodic_entry_id"
  end

  create_table "months", force: :cascade do |t|
    t.integer "name"
    t.integer "total_cents"
    t.string "total_currency", default: "BRL", null: false
    t.bigint "year_id"
    t.index ["year_id", "name"], name: "index_months_on_year_id_and_name", unique: true
    t.index ["year_id"], name: "index_months_on_year_id"
  end

  create_table "periodic_entries", force: :cascade do |t|
    t.json "entry_data", null: false
    t.bigint "start_month_id", null: false
    t.bigint "end_month_id"
    t.integer "interval"
    t.boolean "fulfilled", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["end_month_id"], name: "index_periodic_entries_on_end_month_id"
    t.index ["start_month_id"], name: "index_periodic_entries_on_start_month_id"
  end

  create_table "years", force: :cascade do |t|
    t.integer "name"
    t.float "interest_rate"
    t.index ["name"], name: "index_years_on_name", unique: true
  end

  add_foreign_key "periodic_entries", "months", column: "end_month_id"
  add_foreign_key "periodic_entries", "months", column: "start_month_id"
end
