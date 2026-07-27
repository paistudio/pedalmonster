require "rails_helper"

RSpec.describe "Api::Posts likes", type: :request do
  let(:profile) { create(:profile) }

  describe "POST /api/posts/:id/like" do
    it "increments like_count" do
      post_record = create(:post)

      post "/api/posts/#{post_record.id}/like", headers: auth_headers_for(profile)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["like_count"]).to eq(1)
      expect(post_record.reload.like_count).to eq(1)
    end

    it "is idempotent — liking twice doesn't double count" do
      post_record = create(:post)

      2.times { post "/api/posts/#{post_record.id}/like", headers: auth_headers_for(profile) }

      expect(post_record.reload.like_count).to eq(1)
      expect(PostLike.where(post: post_record, user_id: profile.id).count).to eq(1)
    end

    it "works the same for a comment" do
      comment = create(:post, :comment)

      post "/api/posts/#{comment.id}/like", headers: auth_headers_for(profile)

      expect(response).to have_http_status(:ok)
      expect(comment.reload.like_count).to eq(1)
    end
  end

  describe "DELETE /api/posts/:id/like" do
    it "decrements like_count" do
      post_record = create(:post)
      post_record.post_likes.create!(user_id: profile.id)

      delete "/api/posts/#{post_record.id}/like", headers: auth_headers_for(profile)

      expect(response).to have_http_status(:ok)
      expect(post_record.reload.like_count).to eq(0)
    end

    it "is idempotent — unliking twice is a no-op the second time" do
      post_record = create(:post)

      delete "/api/posts/#{post_record.id}/like", headers: auth_headers_for(profile)
      delete "/api/posts/#{post_record.id}/like", headers: auth_headers_for(profile)

      expect(response).to have_http_status(:ok)
      expect(post_record.reload.like_count).to eq(0)
    end
  end
end
