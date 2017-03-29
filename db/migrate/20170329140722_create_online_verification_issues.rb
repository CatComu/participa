class CreateOnlineVerificationIssues < ActiveRecord::Migration[5.0]
  def up
    create_table :online_verification_issues do |t|
      t.integer :report_id, index: true
      t.integer :label_id, index: true

      t.timestamps
    end

    add_foreign_key :online_verification_issues, :online_verification_events, column: :report_id
    add_foreign_key :online_verification_issues, :online_verification_labels, column: :label_id
  end

  def down
    remove_foreign_key :online_verification_issues, column: :label_id
    remove_foreign_key :online_verification_issues, column: :report_id

    drop_table :online_verification_issues
  end
end
