class AddVoteTownIndexToUsers < ActiveRecord::Migration
  def change
    add_index :users, [:vote_town]
  end
end
