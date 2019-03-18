class DropProposals < ActiveRecord::Migration[5.0]
  def change
    drop_table :proposals, force: :cascade
    drop_table :supports, force: :cascade
  end
end
