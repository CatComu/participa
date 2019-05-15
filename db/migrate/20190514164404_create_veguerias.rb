class CreateVeguerias < ActiveRecord::Migration[5.0]
  def change
    create_table :veguerias do |t|
      t.string :name
      t.string :code
      t.references :province, foreign_key: true
    end
    
    add_index :veguerias, :code, unique: true
  end
end
