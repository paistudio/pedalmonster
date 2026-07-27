class CreatePostLikes < ActiveRecord::Migration[8.1]
  # A like on any Post row — top-level post or comment, since a comment is just a Post with
  # type="comment". Prevents double-liking via the unique index, per docs/02-data-model.md.
  def change
    create_table :post_likes, id: :uuid do |t|
      t.uuid :post_id, null: false
      t.uuid :user_id, null: false
      t.datetime :created_at, null: false
    end

    add_foreign_key :post_likes, :posts, column: :post_id, on_delete: :cascade
    add_foreign_key :post_likes, :profiles, column: :user_id, on_delete: :cascade
    add_index :post_likes, [:post_id, :user_id], unique: true
  end
end
