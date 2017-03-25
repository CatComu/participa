class CreateOnlineVerifications < ActiveRecord::Migration[5.0]
  def up
    create_table :online_verifications do |t|
      t.text :comment
      t.integer :status, null: false
      t.integer :verified_id, index: true, null: false
      t.integer :verifier_id, index: true, null: false

      t.timestamps
    end

    add_foreign_key :online_verifications, :users, column: :verified_id
    add_foreign_key :online_verifications, :users, column: :verifier_id
  end

  def down
    remove_foreign_key :online_verifications, column: :verified_id
    remove_foreign_key :online_verifications, column: :verifier_id

    drop_table :online_verifications
  end
end
