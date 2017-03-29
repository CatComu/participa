class CreateOnlineVerificationEvents < ActiveRecord::Migration[5.0]
  def up
    create_table :online_verification_events do |t|
      t.string :type, null: false
      t.integer :verified_id, index: true, null: false
      t.integer :verifier_id

      t.timestamps
    end

    add_foreign_key :online_verification_events, :users, column: :verified_id
    add_foreign_key :online_verification_events, :users, column: :verifier_id
  end

  def down
    remove_foreign_key :online_verification_events, column: :verified_id
    remove_foreign_key :online_verification_events, column: :verifier_id

    drop_table :online_verification_events
  end
end
