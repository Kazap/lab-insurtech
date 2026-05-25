class CreatePremiumPayments < ActiveRecord::Migration[8.1]
  def change
    create_table :premium_payments do |t|
      t.references :policy, null: false, foreign_key: true
      t.date :reference_month, null: false
      t.date :due_date, null: false
      t.integer :amount_cents, null: false
      t.string :status, default: "pending", null: false
      t.datetime :paid_at

      t.timestamps
    end

    add_index :premium_payments, :status
    add_index :premium_payments, :due_date
  end
end
