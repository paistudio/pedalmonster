# The single content table for every post type AND comments — see docs/02-data-model.md.
# A "comment" is not a separate model, it's a Post row with type="comment" and parent_id set.
class Post < ApplicationRecord
  # 'type' is a plain enum-ish string column here, not a Rails STI discriminator.
  self.inheritance_column = nil

  TYPES = %w[listing community_post group_post comment].freeze

  belongs_to :author, class_name: "Profile", foreign_key: :user_id, inverse_of: :posts
  belongs_to :parent, class_name: "Post", foreign_key: :parent_id, optional: true,
                       inverse_of: :comments, counter_cache: :comment_count
  belongs_to :city, foreign_key: :location_city_id, optional: true
  has_many :comments, class_name: "Post", foreign_key: :parent_id, inverse_of: :parent
  has_many :post_likes, inverse_of: :post

  validates :type, presence: true, inclusion: { in: TYPES }
  validates :parent_id, presence: true, if: -> { type == "comment" }
  validates :parent_id, absence: true, unless: -> { type == "comment" }
  validates :description, presence: true, unless: -> { type == "comment" && media_urls.present? }

  before_save :set_mentioned_user_ids, if: -> { type == "comment" }

  scope :top_level, -> { where.not(type: "comment") }

  private

  # Derived from @username tokens in the comment body — only usernames matching a real
  # account count, see docs/02-data-model.md. Recomputed on every save so editing a comment
  # keeps mentions in sync, not just on initial create.
  def set_mentioned_user_ids
    handles = description.to_s.scan(/@([a-zA-Z0-9._]+)/).flatten.map(&:downcase).uniq
    self.mentioned_user_ids = handles.empty? ? [] : Profile.where("lower(username) IN (?)", handles).pluck(:id)
  end
end
