class CreateDistricts < ActiveRecord::Migration[5.0]
  def change
    create_table :districts do |t|
      t.string :name
      t.integer :code
      t.references :vegueria, foreign_key: true
    end

    add_index :districts, :code, unique: true
  end
end
