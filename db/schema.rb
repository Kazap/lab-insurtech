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

ActiveRecord::Schema[8.1].define(version: 2026_01_01_000005) do
  create_table "claims", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.date "incident_date", null: false
    t.integer "payout_amount_cents"
    t.integer "policy_coverage_id", null: false
    t.integer "policy_id", null: false
    t.integer "requested_amount_cents", null: false
    t.string "status", default: "open", null: false
    t.datetime "updated_at", null: false
    t.index ["incident_date"], name: "index_claims_on_incident_date"
    t.index ["policy_coverage_id"], name: "index_claims_on_policy_coverage_id"
    t.index ["policy_id", "status"], name: "index_claims_on_policy_id_and_status"
    t.index ["policy_id"], name: "index_claims_on_policy_id"
    t.index ["status"], name: "index_claims_on_status"
  end

  create_table "policies", force: :cascade do |t|
    t.integer "coverage_amount_cents", null: false
    t.datetime "created_at", null: false
    t.date "effective_date", null: false
    t.date "expiration_date", null: false
    t.integer "monthly_premium_cents", null: false
    t.string "policy_type", null: false
    t.integer "policyholder_id", null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.index ["policyholder_id", "status"], name: "index_policies_on_policyholder_id_and_status"
    t.index ["policyholder_id"], name: "index_policies_on_policyholder_id"
    t.index ["status"], name: "index_policies_on_status"
  end

  create_table "policy_coverages", force: :cascade do |t|
    t.integer "coverage_percentage", default: 100, null: false
    t.string "coverage_type", null: false
    t.datetime "created_at", null: false
    t.integer "deductible_cents", default: 0, null: false
    t.integer "max_coverage_cents", null: false
    t.integer "policy_id", null: false
    t.datetime "updated_at", null: false
    t.index ["coverage_type"], name: "index_policy_coverages_on_coverage_type"
    t.index ["policy_id"], name: "index_policy_coverages_on_policy_id"
  end

  create_table "policyholders", force: :cascade do |t|
    t.date "birthdate", null: false
    t.string "cpf", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "phone"
    t.string "risk_profile", default: "medium", null: false
    t.datetime "updated_at", null: false
    t.index ["cpf"], name: "index_policyholders_on_cpf", unique: true
    t.index ["email"], name: "index_policyholders_on_email"
  end

  create_table "premium_payments", force: :cascade do |t|
    t.integer "amount_cents", null: false
    t.datetime "created_at", null: false
    t.date "due_date", null: false
    t.datetime "paid_at"
    t.integer "policy_id", null: false
    t.date "reference_month", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["due_date"], name: "index_premium_payments_on_due_date"
    t.index ["policy_id"], name: "index_premium_payments_on_policy_id"
    t.index ["status"], name: "index_premium_payments_on_status"
  end

  add_foreign_key "claims", "policies"
  add_foreign_key "claims", "policy_coverages"
  add_foreign_key "policies", "policyholders"
  add_foreign_key "policy_coverages", "policies"
  add_foreign_key "premium_payments", "policies"
end
