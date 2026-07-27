require "rails_helper"

RSpec.describe "Api::Posts", type: :request do
  let(:profile) { create(:profile) }

  describe "GET /api/feed" do
    it "returns top-level posts only, newest first" do
      older = create(:post, description: "older", created_at: 1.day.ago)
      newer = create(:post, description: "newer")
      create(:post, :comment, parent: older)

      get "/api/feed", headers: auth_headers_for(profile)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.size).to eq(2)
      expect(body.first["id"]).to eq(newer.id)
      expect(body.map { |p| p["type"] }).not_to include("comment")
    end
  end

  describe "GET /api/posts/:id" do
    it "includes the comment thread" do
      post_record = create(:post)
      comment = create(:post, :comment, parent: post_record)

      get "/api/posts/#{post_record.id}", headers: auth_headers_for(profile)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["comments"].map { |c| c["id"] }).to eq([comment.id])
    end
  end

  describe "POST /api/posts" do
    it "creates a post owned by the current profile" do
      post "/api/posts",
           params: { type: "community_post", description: "Anyone doing a night ride?" },
           headers: auth_headers_for(profile)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["user_id"]).to eq(profile.id)
    end

    it "rejects an unknown type" do
      post "/api/posts", params: { type: "nonsense", description: "x" }, headers: auth_headers_for(profile)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /api/posts/:id" do
    it "lets the owner edit their post" do
      owned = create(:post, author: profile)

      patch "/api/posts/#{owned.id}", params: { description: "updated" }, headers: auth_headers_for(profile)

      expect(response).to have_http_status(:ok)
      expect(owned.reload.description).to eq("updated")
    end

    it "forbids editing someone else's post" do
      someone_elses = create(:post)

      patch "/api/posts/#{someone_elses.id}", params: { description: "hijacked" }, headers: auth_headers_for(profile)

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "DELETE /api/posts/:id" do
    it "cascades to delete comments" do
      owned = create(:post, author: profile)
      comment = create(:post, :comment, parent: owned)

      delete "/api/posts/#{owned.id}", headers: auth_headers_for(profile)

      expect(response).to have_http_status(:no_content)
      expect(Post.exists?(comment.id)).to be false
    end
  end

  describe "comments" do
    it "creates a comment, extracts mentions, and bumps the parent's comment_count" do
      mentioned = create(:profile, username: "trailblazer")
      post_record = create(:post)

      post "/api/posts/#{post_record.id}/comments",
           params: { description: "great tip @trailblazer!" },
           headers: auth_headers_for(profile)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["type"]).to eq("comment")
      expect(body["mentioned_user_ids"]).to eq([mentioned.id])
      expect(post_record.reload.comment_count).to eq(1)
    end

    it "lists comments for a post" do
      post_record = create(:post)
      create(:post, :comment, parent: post_record)

      get "/api/posts/#{post_record.id}/comments", headers: auth_headers_for(profile)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(1)
    end
  end

  describe "GET /api/listings" do
    it "filters by category" do
      bike = create(:post, :listing)
      create(:post, :listing, type_data: { "category" => "part", "condition" => "new", "price" => 500_000 })

      get "/api/listings", params: { category: "bike" }, headers: auth_headers_for(profile)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.map { |p| p["id"] }).to eq([bike.id])
    end
  end
end
