class DropBlogs < ActiveRecord::Migration[5.0]
  def change
    drop_table :posts, force: :cascade
    drop_table :categories_posts, force: :cascade
  end
end
