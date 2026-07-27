require "rails_helper"

RSpec.describe "Api::Users", type: :request do
  describe "GET /api/users/:id" do
    it "returns the profile, including a derived rank" do
      profile = create(:profile, points: 60)

      get "/api/users/#{profile.id}", headers: auth_headers_for(profile)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["username"]).to eq(profile.username)
      expect(body["rank"]).to eq("Rider")
    end
  end

  describe "PATCH /api/users/:id" do
    it "lets a profile update its own username/bio/location" do
      profile = create(:profile)

      patch "/api/users/#{profile.id}",
            params: { username: "new_handle", bio: "I ride bikes" },
            headers: auth_headers_for(profile)

      expect(response).to have_http_status(:ok)
      expect(profile.reload.username).to eq("new_handle")
      expect(profile.bio).to eq("I ride bikes")
    end

    it "forbids updating someone else's profile" do
      profile = create(:profile)
      other = create(:profile)

      patch "/api/users/#{other.id}", params: { username: "hijacked" }, headers: auth_headers_for(profile)

      expect(response).to have_http_status(:forbidden)
      expect(other.reload.username).not_to eq("hijacked")
    end

    it "ignores an attempt to change email through this endpoint" do
      profile = create(:profile)

      patch "/api/users/#{profile.id}", params: { email: "new@example.com" }, headers: auth_headers_for(profile)

      expect(response).to have_http_status(:ok)
    end
  end
end
