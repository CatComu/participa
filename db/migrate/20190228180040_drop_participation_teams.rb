class DropParticipationTeams < ActiveRecord::Migration[5.0]
  def change
    drop_table :participation_teams, force: :cascade
    drop_table :participation_teams_users, force: :cascade
  end
end
