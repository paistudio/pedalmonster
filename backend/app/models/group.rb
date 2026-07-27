# See docs/02-data-model.md and docs/10-groups.md. Public-only in MVP, single owner, no
# roles/moderation beyond owner-block.
class Group < ApplicationRecord
  belongs_to :owner, class_name: "Profile", foreign_key: :created_by, inverse_of: false
  belongs_to :city, foreign_key: :location_city_id, optional: true
  has_many :group_memberships, dependent: :destroy
  has_many :members, through: :group_memberships, source: :user

  validates :name, presence: true
  validates :visibility, inclusion: { in: %w[public] }

  before_destroy :destroy_group_posts

  def blocked?(user_id)
    blocked_user_ids.include?(user_id)
  end

  private

  # group_post's group_id lives inside Post#type_data (jsonb), not a real FK column, so this
  # can't be a normal `has_many ... dependent: :destroy` — see docs/10-groups.md's Delete Group.
  def destroy_group_posts
    Post.where(type: "group_post").where("type_data ->> 'group_id' = ?", id.to_s).destroy_all
  end
end
