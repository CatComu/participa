class ChangeIdToCatalanTowns < ActiveRecord::Migration[5.0]
  def change
    rename_column :catalan_towns, :id, :code
    execute "ALTER TABLE catalan_towns DROP CONSTRAINT catalan_towns_pkey"
    add_column :catalan_towns, :id, :primary_key
    add_index :catalan_towns, :code
  end
end
