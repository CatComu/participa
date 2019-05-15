class AddPolimorphicToGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :territory_id, :integer
    add_column :groups, :territory_type, :string
    add_index :groups, [:territory_id, :territory_type]
  end
end
