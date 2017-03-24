class CreateIdentityDocuments < ActiveRecord::Migration[5.0]
  def change
    create_table :identity_documents do |t|
      t.references :user, foreign_key: true, null: false

      t.string :scanned_picture_file_name
      t.string :scanned_picture_content_type
      t.integer :scanned_picture_file_size
      t.datetime :scanned_picture_updated_at

      t.timestamps
    end
  end
end
