class CreatePolicyholders < ActiveRecord::Migration[8.1]
  def change
    create_table :policyholders do |t|
      t.string :name, null: false
      t.string :cpf, null: false
      t.string :email, null: false
      t.string :phone
      t.date :birthdate, null: false
      t.string :risk_profile, default: "medium", null: false

      t.timestamps
    end

    add_index :policyholders, :cpf, unique: true
    add_index :policyholders, :email
  end
end
