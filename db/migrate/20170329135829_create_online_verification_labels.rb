class CreateOnlineVerificationLabels < ActiveRecord::Migration[5.0]
  def up
    create_table :online_verification_labels do |t|
      t.string :code

      t.timestamps
    end

    execute <<~SQL.squish
      INSERT INTO online_verification_labels(code, created_at, updated_at)
      VALUES ('invalid_id', now(), now()),
             ('unverifiable_id', now(), now()),
             ('unmatched_identity', now(), now()),
             ('non_local_id_with_missing_residence_proof', now(), now()),
             ('non_local_id_with_outdated_residence_proof', now(), now()),
             ('non_local_id_with_unmatched_residence_proof', now(), now()),
             ('non_local_id_with_unverifiable_residence_proof', now(), now())
    SQL
  end

  def down
    drop_table :online_verification_labels
  end
end
