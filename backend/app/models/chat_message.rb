# 'type' is a plain enum column (text/product), not Rails STI — same pattern as Post.
class ChatMessage < ApplicationRecord
  self.inheritance_column = nil

  TYPES = %w[text product].freeze

  belongs_to :chat_thread
  belongs_to :sender, class_name: "Profile", foreign_key: :sender_id, inverse_of: false
  belongs_to :listing, class_name: "Post", foreign_key: :listing_id, optional: true

  validates :type, inclusion: { in: TYPES }
  # Text messages may be photo-only (media_urls non-empty, no body); product messages carry
  # no body/media of their own, just a listing reference — see docs/02-data-model.md.
  validates :body, presence: true, unless: -> { type == "product" || media_urls.present? }
end
