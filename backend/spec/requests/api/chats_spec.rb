require "rails_helper"

RSpec.describe "Api::Chats", type: :request do
  let(:profile) { create(:profile) }
  let(:other) { create(:profile) }

  describe "POST /api/chats/:user_id/messages" do
    it "sends a text message and creates the thread on first send" do
      post "/api/chats/#{other.id}/messages", params: { body: "Halo, masih ready?" },
                                                headers: auth_headers_for(profile)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["sender_id"]).to eq(profile.id)
      expect(body["body"]).to eq("Halo, masih ready?")
      expect(ChatThread.count).to eq(1)
    end

    it "supports a photo-only message" do
      post "/api/chats/#{other.id}/messages", params: { media_urls: ["blob:one"] },
                                                headers: auth_headers_for(profile)

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["media_urls"]).to eq(["blob:one"])
    end

    it "reuses the same thread regardless of who initiates" do
      post "/api/chats/#{other.id}/messages", params: { body: "hi" }, headers: auth_headers_for(profile)
      post "/api/chats/#{profile.id}/messages", params: { body: "hey back" }, headers: auth_headers_for(other)

      expect(ChatThread.count).to eq(1)
    end
  end

  describe "GET /api/chats/:user_id/messages" do
    it "returns messages in order" do
      post "/api/chats/#{other.id}/messages", params: { body: "first" }, headers: auth_headers_for(profile)
      post "/api/chats/#{profile.id}/messages", params: { body: "second" }, headers: auth_headers_for(other)

      get "/api/chats/#{other.id}/messages", headers: auth_headers_for(profile)

      expect(response).to have_http_status(:ok)
      bodies = JSON.parse(response.body).map { |m| m["body"] }
      expect(bodies).to eq(["first", "second"])
    end

    it "returns an empty list when no thread exists yet" do
      get "/api/chats/#{other.id}/messages", headers: auth_headers_for(profile)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq([])
    end
  end

  describe "GET /api/chats and POST /api/chats/:user_id/read" do
    it "shows unread until the recipient marks it read" do
      post "/api/chats/#{other.id}/messages", params: { body: "hi" }, headers: auth_headers_for(profile)

      get "/api/chats", headers: auth_headers_for(other)
      expect(JSON.parse(response.body).first["unread"]).to be true

      post "/api/chats/#{profile.id}/read", headers: auth_headers_for(other)

      get "/api/chats", headers: auth_headers_for(other)
      expect(JSON.parse(response.body).first["unread"]).to be false
    end
  end
end
