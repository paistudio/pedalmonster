# Shared JSON shape for a Post row (top-level post or comment) — used by PostsController and
# the nested comments controller so both stay in sync with docs/02-data-model.md's Post entity.
class PostSerializer
  FIELDS = %i[
    id user_id type parent_id title description media_urls tags mentioned_user_ids
    location location_city_id like_count comment_count created_at type_data
  ].freeze

  def self.call(post, include_comments: false)
    json = post.as_json(only: FIELDS)
    json["comments"] = post.comments.order(:created_at).map { |c| call(c) } if include_comments
    json
  end
end
