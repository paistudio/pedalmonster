module Api
  module Posts
    # Nested under a post — POST /api/posts/:id/comments creates a Post row with
    # type="comment" and parent_id=:id, per docs/02-data-model.md. Editing/deleting a comment
    # goes through the same Api::PostsController#update/#destroy as any other post row, since
    # it's the same underlying resource.
    class CommentsController < Api::BaseController
      def index
        parent = Post.find(params[:post_id])
        render json: parent.comments.order(:created_at).map { |comment| PostSerializer.call(comment) }
      end

      def create
        parent = Post.find(params[:post_id])
        comment = current_profile.posts.build(comment_params.merge(type: "comment", parent_id: parent.id))

        if comment.save
          render json: PostSerializer.call(comment), status: :created
        else
          render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def comment_params
        params.permit(:description, media_urls: [])
      end
    end
  end
end
