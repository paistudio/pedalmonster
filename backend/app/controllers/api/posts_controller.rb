module Api
  class PostsController < BaseController
    before_action :set_post, only: [:show, :update, :destroy, :like, :unlike]
    before_action :require_ownership!, only: [:update, :destroy]

    # GET /api/feed — unified feed, paginated, mixed top-level post types (type != comment)
    def feed
      posts = Post.top_level.order(created_at: :desc).limit(50)
      render json: posts.map { |post| PostSerializer.call(post) }
    end

    def show
      render json: PostSerializer.call(@post, include_comments: true)
    end

    def create
      post = current_profile.posts.build(post_params)
      if post.save
        render json: PostSerializer.call(post), status: :created
      else
        render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      if @post.update(post_params)
        render json: PostSerializer.call(@post)
      else
        render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @post.destroy
      head :no_content
    end

    # Same endpoint for liking a top-level post or a comment, since both are Post rows —
    # idempotent: find_or_create_by (plus the DB unique index) means liking twice doesn't
    # double the count, per docs/02-data-model.md's PostLike notes.
    def like
      @post.post_likes.find_or_create_by(user_id: current_profile.id)
      render json: { like_count: @post.reload.like_count }
    end

    def unlike
      @post.post_likes.where(user_id: current_profile.id).destroy_all
      render json: { like_count: @post.reload.like_count }
    end

    private

    def set_post
      @post = Post.find(params[:id])
    end

    # Owner-only edit/delete — applies to both a top-level post and a comment (a comment is
    # author-only rather than post-owner-only, but it's the same `user_id == current_profile.id`
    # check either way), per docs/02-data-model.md.
    def require_ownership!
      return if @post.user_id == current_profile.id

      render json: { error: "Forbidden" }, status: :forbidden
    end

    def post_params
      params.permit(:type, :title, :description, :location, :location_city_id,
                     media_urls: [], tags: [], type_data: {})
    end
  end
end
