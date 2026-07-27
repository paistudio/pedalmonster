module Api
  # Tag detail + follow/unfollow, per docs/13-tags-and-topic-discovery.md and
  # docs/02-data-model.md's Tag/TagFollow notes. Tag names aren't UUIDs, so routes accept any
  # non-slash string (see config/routes.rb).
  class TagsController < BaseController
    NEW_POST_WINDOW = 3.days

    def show
      tag_name = params[:name]
      posts = matching_posts(tag_name)

      render json: {
        name: tag_name,
        follower_count: TagFollow.where(tag_name: tag_name).count,
        following: TagFollow.exists?(tag_name: tag_name, user_id: current_profile.id),
        new_post_count: posts.where("created_at >= ?", NEW_POST_WINDOW.ago).count,
        posts: posts.limit(50).map { |post| PostSerializer.call(post) }
      }
    end

    def follow
      TagFollow.find_or_create_by(user_id: current_profile.id, tag_name: params[:name])
      render json: { follower_count: TagFollow.where(tag_name: params[:name]).count }
    end

    def unfollow
      TagFollow.where(user_id: current_profile.id, tag_name: params[:name]).destroy_all
      render json: { follower_count: TagFollow.where(tag_name: params[:name]).count }
    end

    private

    def matching_posts(tag_name)
      Post.top_level.where("? = ANY(tags)", tag_name).order(created_at: :desc)
    end
  end
end
