class CreateNotifications < ActiveRecord::Migration[8.1]
  # post_id/group_id are mutually exclusive depending on what triggered it, per
  # docs/02-data-model.md. read_at null means unread.
  def change
    create_table :notifications, id: :uuid do |t|
      t.uuid :user_id, null: false
      t.string :title, null: false
      t.string :body
      t.uuid :post_id
      t.uuid :group_id
      t.datetime :read_at
      t.datetime :created_at, null: false
    end

    add_foreign_key :notifications, :profiles, column: :user_id, on_delete: :cascade
    add_foreign_key :notifications, :posts, column: :post_id, on_delete: :cascade
    add_foreign_key :notifications, :groups, column: :group_id, on_delete: :cascade
    add_index :notifications, [:user_id, :read_at]
  end
end
