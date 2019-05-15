class CreateTerritoryJoinTables < ActiveRecord::Migration[5.0]
  def change
    remove_index :veguerias, :province_id
    remove_column :veguerias, :province_id

    remove_index :districts, :vegueria_id
    remove_column :districts, :vegueria_id

    create_join_table :provinces, :veguerias do |t|
      t.index [:province_id, :vegueria_id]
    end

    create_join_table :districts, :provinces do |t|
      t.index [:district_id, :province_id]
    end

    create_join_table :districts, :veguerias do |t|
      t.index [:district_id, :vegueria_id]
    end
  end
end
