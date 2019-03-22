class CreateGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :groups do |t|
      t.string :name
      t.date :starts_at
      t.date :ends_at
      t.boolean :is_institutional, default: false
      t.boolean :has_location, default: false
      t.integer :location_type, default: nil
      t.boolean :has_space, default: false
      t.string :space_type

      t.timestamps
    end
  end
end
