require "rails_helper"

RSpec.describe "Api::Groups", type: :request do
  let(:profile) { create(:profile) }

  describe "POST /api/groups" do
    it "creates a group and auto-joins the creator as the sole member" do
      post "/api/groups", params: { name: "MTB Trail Hunter Bogor", description: "Weekend trail rides" },
                           headers: auth_headers_for(profile)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["created_by"]).to eq(profile.id)
      expect(body["member_count"]).to eq(1)
    end
  end

  describe "GET /api/groups" do
    it "?mine=1 only returns groups the profile has joined" do
      mine = create(:group, owner: profile)
      mine.group_memberships.create!(user_id: profile.id)
      create(:group)

      get "/api/groups", params: { mine: 1 }, headers: auth_headers_for(profile)

      body = JSON.parse(response.body)
      expect(body.map { |g| g["id"] }).to eq([mine.id])
    end
  end

  describe "POST /api/groups/:id/join and leave" do
    it "joining increments member_count, leaving decrements it" do
      group = create(:group)

      post "/api/groups/#{group.id}/join", headers: auth_headers_for(profile)
      expect(JSON.parse(response.body)["member_count"]).to eq(1)

      delete "/api/groups/#{group.id}/join", headers: auth_headers_for(profile)
      expect(JSON.parse(response.body)["member_count"]).to eq(0)
    end

    it "silently no-ops joining for a blocked user" do
      group = create(:group, blocked_user_ids: [profile.id])

      post "/api/groups/#{group.id}/join", headers: auth_headers_for(profile)

      expect(response).to have_http_status(:ok)
      expect(group.group_memberships.exists?(user_id: profile.id)).to be false
    end
  end

  describe "POST /api/groups/:id/block" do
    it "is owner-only" do
      group = create(:group)
      member = create(:profile)
      group.group_memberships.create!(user_id: member.id)

      post "/api/groups/#{group.id}/block", params: { user_id: member.id }, headers: auth_headers_for(profile)

      expect(response).to have_http_status(:forbidden)
    end

    it "removes membership and prevents rejoining" do
      group = create(:group, owner: profile)
      member = create(:profile)
      group.group_memberships.create!(user_id: member.id)

      post "/api/groups/#{group.id}/block", params: { user_id: member.id }, headers: auth_headers_for(profile)
      expect(response).to have_http_status(:ok)
      expect(group.group_memberships.exists?(user_id: member.id)).to be false

      post "/api/groups/#{group.id}/join", headers: auth_headers_for(member)
      expect(group.group_memberships.exists?(user_id: member.id)).to be false
    end
  end

  describe "DELETE /api/groups/:id" do
    it "cascades to memberships and group_posts" do
      group = create(:group, owner: profile)
      group.group_memberships.create!(user_id: profile.id)
      group_post = create(:post, type: "group_post", author: profile, description: "ride recap",
                                  type_data: { "group_id" => group.id })

      delete "/api/groups/#{group.id}", headers: auth_headers_for(profile)

      expect(response).to have_http_status(:no_content)
      expect(Post.exists?(group_post.id)).to be false
    end
  end
end
