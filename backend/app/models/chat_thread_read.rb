class ChatThreadRead < ApplicationRecord
  belongs_to :chat_thread
  belongs_to :user, class_name: "Profile", foreign_key: :user_id, inverse_of: false
end
