require "rails_helper"

RSpec.describe "Api::Tags", type: :request do
  let(:profile) { create(:profile) }

  describe "GET /api/tags/:name" do
    it "returns follower count, following state, and matching posts" do
      create(:post, tags: ["MTB"])
      TagFollow.create!(user_id: profile.id, tag_name: "MTB")
      other = create(:profile)
      TagFollow.create!(user_id: other.id, tag_name: "MTB")

      get "/api/tags/MTB", headers: auth_headers_for(profile)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["follower_count"]).to eq(2)
      expect(body["following"]).to be true
      expect(body["posts"].size).to eq(1)
    end
  end

  describe "follow / unfollow" do
    it "follows then unfollows a tag" do
      post "/api/tags/Trail/follow", headers: auth_headers_for(profile)
      expect(JSON.parse(response.body)["follower_count"]).to eq(1)

      delete "/api/tags/Trail/follow", headers: auth_headers_for(profile)
      expect(JSON.parse(response.body)["follower_count"]).to eq(0)
    end

    it "is idempotent" do
      2.times { post "/api/tags/Trail/follow", headers: auth_headers_for(profile) }
      expect(TagFollow.where(user_id: profile.id, tag_name: "Trail").count).to eq(1)
    end
  end

  describe "GET /api/users/:id/followed-tags" do
    it "lists the profile's followed tags" do
      TagFollow.create!(user_id: profile.id, tag_name: "MTB")
      TagFollow.create!(user_id: profile.id, tag_name: "Commuter")

      get "/api/users/#{profile.id}/followed-tags", headers: auth_headers_for(profile)

      expect(JSON.parse(response.body)).to eq(["Commuter", "MTB"])
    end

    it "is owner-only" do
      other = create(:profile)

      get "/api/users/#{other.id}/followed-tags", headers: auth_headers_for(profile)

      expect(response).to have_http_status(:forbidden)
    end
  end
end
