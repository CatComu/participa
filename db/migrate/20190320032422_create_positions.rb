class CreatePositions < ActiveRecord::Migration[5.0]
  def change
    create_table :positions do |t|
      t.string :name
      t.integer :position_type, default: nil
      t.references :group, foreign_key: true

      t.timestamps
    end
    
    create_table :positions_users, id: false do |t|
      t.integer :position_id, index: true
      t.integer :user_id, index: true
    end
  end
end
