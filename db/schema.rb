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

ActiveRecord::Schema[8.0].define(version: 2025_03_17_023840) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "moisture_readings", force: :cascade do |t|
    t.bigint "plant_id", null: false
    t.integer "moisture_level", null: false
    t.datetime "recorded_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plant_id"], name: "index_moisture_readings_on_plant_id"
    t.index ["recorded_at"], name: "index_moisture_readings_on_recorded_at"
  end

  create_table "plants", force: :cascade do |t|
    t.string "slug"
    t.string "species"
    t.string "location"
    t.integer "preferred_moisture_min"
    t.integer "preferred_moisture_max"
    t.text "care_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_plants_on_slug", unique: true
  end

  add_foreign_key "moisture_readings", "plants"
end
