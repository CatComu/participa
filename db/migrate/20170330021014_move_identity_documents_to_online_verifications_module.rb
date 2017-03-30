class MoveIdentityDocumentsToOnlineVerificationsModule < ActiveRecord::Migration[5.0]
  def change
    rename_table :identity_documents, :online_verification_documents
    rename_column :online_verification_documents, :user_id, :upload_id
  end
end
