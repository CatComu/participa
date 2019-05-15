class CreateProvinces < ActiveRecord::Migration[5.0]
  def change
    create_table :provinces do |t|
      t.string :name
      t.integer :code
    end
    
    add_index :provinces, :code, unique: true
  end
end
