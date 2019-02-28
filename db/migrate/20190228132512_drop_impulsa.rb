class DropImpulsa < ActiveRecord::Migration[5.0]
  def change
    drop_table :impulsa_editions, force: :cascade
    drop_table :impulsa_edition_categories, force: :cascade
    drop_table :impulsa_edition_topics, force: :cascade
    drop_table :impulsa_projects, force: :cascade
    drop_table :impulsa_project_topics, force: :cascade
  end
end
