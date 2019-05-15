class ChangeSpaceTypeToDescription < ActiveRecord::Migration[5.0]
  def change
    rename_column :groups, :space_type, :description
    remove_column :groups, :has_space
  end
end
