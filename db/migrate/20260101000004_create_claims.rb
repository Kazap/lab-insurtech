class CreateClaims < ActiveRecord::Migration[8.1]
  def change
    create_table :claims do |t|
      t.references :policy, null: false, foreign_key: true
      t.references :policy_coverage, null: false, foreign_key: true
      t.string :status, default: "open", null: false
      t.date :incident_date, null: false
      t.text :description, null: false
      t.integer :requested_amount_cents, null: false
      t.integer :payout_amount_cents

      t.timestamps
    end

    add_index :claims, :status
    add_index :claims, :incident_date
    add_index :claims, [:policy_id, :status]
  end
end
