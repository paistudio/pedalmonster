class CreateChatThreadReads < ActiveRecord::Migration[8.1]
  # Tracks each participant's read position in a thread — see docs/02-data-model.md.
  def change
    create_table :chat_thread_reads, id: :uuid do |t|
      t.uuid :chat_thread_id, null: false
      t.uuid :user_id, null: false
      t.datetime :last_read_at
    end

    add_foreign_key :chat_thread_reads, :chat_threads, column: :chat_thread_id, on_delete: :cascade
    add_foreign_key :chat_thread_reads, :profiles, column: :user_id, on_delete: :cascade
    add_index :chat_thread_reads, [:chat_thread_id, :user_id], unique: true
  end
end
