class CreateChatThreads < ActiveRecord::Migration[8.1]
  # A DM thread between exactly two users, keyed by the unordered participant pair — see
  # docs/02-data-model.md. The check constraint forces callers to always store the pair in a
  # canonical order (see ChatThread.between), so the same two people can't get two threads.
  def change
    create_table :chat_threads, id: :uuid do |t|
      t.uuid :user_one_id, null: false
      t.uuid :user_two_id, null: false
      t.datetime :created_at, null: false
    end

    add_foreign_key :chat_threads, :profiles, column: :user_one_id, on_delete: :cascade
    add_foreign_key :chat_threads, :profiles, column: :user_two_id, on_delete: :cascade
    add_index :chat_threads, [:user_one_id, :user_two_id], unique: true
    add_check_constraint :chat_threads, "user_one_id < user_two_id", name: "chat_threads_ordered_pair"
  end
end
