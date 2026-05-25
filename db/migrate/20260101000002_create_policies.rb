class CreatePolicies < ActiveRecord::Migration[8.1]
  def change
    create_table :policies do |t|
      t.references :policyholder, null: false, foreign_key: true
      t.string :policy_type, null: false
      t.string :status, default: "active", null: false
      t.date :effective_date, null: false
      t.date :expiration_date, null: false
      t.integer :coverage_amount_cents, null: false
      t.integer :monthly_premium_cents, null: false

      t.timestamps
    end

    add_index :policies, :status
    add_index :policies, [:policyholder_id, :status]
  end
end
