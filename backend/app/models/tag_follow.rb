# See docs/02-data-model.md's Tag/TagFollow notes — tag_name is matched against Post#tags
# as a plain string, not a hard FK to a curated Tag table (there isn't one in MVP).
class TagFollow < ApplicationRecord
  belongs_to :user, class_name: "Profile", foreign_key: :user_id, inverse_of: false

  before_validation { self.tag_name = tag_name.to_s.strip }

  validates :tag_name, presence: true, uniqueness: { scope: :user_id }
end
