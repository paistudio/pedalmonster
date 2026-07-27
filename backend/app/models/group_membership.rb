class GroupMembership < ApplicationRecord
  belongs_to :group, counter_cache: :member_count
  belongs_to :user, class_name: "Profile", foreign_key: :user_id, inverse_of: false

  validates :user_id, uniqueness: { scope: :group_id }

  before_validation { self.joined_at ||= Time.current }
end
