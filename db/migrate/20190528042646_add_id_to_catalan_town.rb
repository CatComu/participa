class AddIdToCatalanTown < ActiveRecord::Migration[5.0]
  def up
    rename_column :catalan_towns, :code, :id
  end

  def down
    rename_column :catalan_towns, :id, :code
  end
end
