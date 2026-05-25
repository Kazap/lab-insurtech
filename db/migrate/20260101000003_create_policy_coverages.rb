class CreatePolicyCoverages < ActiveRecord::Migration[8.1]
  def change
    create_table :policy_coverages do |t|
      t.references :policy, null: false, foreign_key: true
      t.string :coverage_type, null: false
      t.integer :max_coverage_cents, null: false
      t.integer :deductible_cents, default: 0, null: false
      t.integer :coverage_percentage, default: 100, null: false

      t.timestamps
    end

    add_index :policy_coverages, :coverage_type
  end
end
