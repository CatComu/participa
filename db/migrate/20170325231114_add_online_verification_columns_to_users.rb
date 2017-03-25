class AddOnlineVerificationColumnsToUsers < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :verified_online_by_id, :integer
    add_column :users, :verified_online_at, :datetime

    add_foreign_key :users, :users, column: :verified_online_by_id
  end

  def down
    remove_foreign_key :users, column: :verified_online_by_id

    remove_column :users, :verified_online_by_id, :integer
    remove_column :users, :verified_online_at, :datetime
  end
end
