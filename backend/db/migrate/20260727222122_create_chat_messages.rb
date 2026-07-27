class CreateChatMessages < ActiveRecord::Migration[8.1]
  # 'type' is a plain enum column (text/product), not Rails STI — disabled on the model, same
  # pattern as Post. media_urls supports the photo-attachment chat feature, see
  # docs/14-inbox-notifications-and-chat.md's Chat Thread Composer.
  def change
    create_table :chat_messages, id: :uuid do |t|
      t.uuid :chat_thread_id, null: false
      t.uuid :sender_id, null: false
      t.string :type, null: false, default: "text"
      t.text :body
      t.text :media_urls, array: true, null: false, default: []
      t.uuid :listing_id
      t.datetime :created_at, null: false
    end

    add_foreign_key :chat_messages, :chat_threads, column: :chat_thread_id, on_delete: :cascade
    add_foreign_key :chat_messages, :profiles, column: :sender_id, on_delete: :cascade
    add_foreign_key :chat_messages, :posts, column: :listing_id
    add_index :chat_messages, :chat_thread_id
  end
end
