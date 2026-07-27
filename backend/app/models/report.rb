# See docs/02-data-model.md. post_id is null for the general "Report a problem" drawer form,
# set for a per-post "Report post" action (which is reason-only, no free-text required).
class Report < ApplicationRecord
  CATEGORIES = %w[bug content spam harassment account other].freeze

  belongs_to :user, class_name: "Profile", foreign_key: :user_id, inverse_of: false
  belongs_to :post, optional: true

  validates :category, inclusion: { in: CATEGORIES }
  validates :description, presence: true, if: -> { post_id.blank? }
end
