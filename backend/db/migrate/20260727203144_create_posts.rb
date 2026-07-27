class CreatePosts < ActiveRecord::Migration[8.1]
  # The single content table for every post type AND comments, per docs/02-data-model.md —
  # a comment is a row with type="comment" and parent_id set. `type` is a plain string column
  # here, not Rails STI (disabled on the model, see app/models/post.rb) — it's just this
  # entity's own type discriminator, matching the doc's field name exactly.
  def change
    create_table :posts, id: :uuid do |t|
      t.uuid :user_id, null: false
      t.string :type, null: false
      t.uuid :parent_id
      t.string :title
      t.text :description
      t.text :media_urls, array: true, null: false, default: []
      t.text :tags, array: true, null: false, default: []
      t.uuid :mentioned_user_ids, array: true, null: false, default: []
      t.string :location
      t.uuid :location_city_id
      t.integer :like_count, null: false, default: 0
      t.integer :comment_count, null: false, default: 0
      t.jsonb :type_data, null: false, default: {}

      t.timestamps
    end

    add_foreign_key :posts, :profiles, column: :user_id
    add_foreign_key :posts, :posts, column: :parent_id, on_delete: :cascade
    add_foreign_key :posts, :cities, column: :location_city_id

    add_index :posts, :type
    add_index :posts, :parent_id
    add_index :posts, :user_id
    add_index :posts, :tags, using: :gin
    add_index :posts, :created_at
  end
end
