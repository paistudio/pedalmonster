# A like on any Post row (top-level post or comment) — see docs/02-data-model.md.
class PostLike < ApplicationRecord
  belongs_to :post, counter_cache: :like_count
  belongs_to :user, class_name: "Profile", foreign_key: :user_id, inverse_of: false

  validates :user_id, uniqueness: { scope: :post_id }
end
