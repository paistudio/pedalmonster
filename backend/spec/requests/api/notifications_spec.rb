require "rails_helper"

RSpec.describe "Api::Notifications", type: :request do
  let(:profile) { create(:profile) }

  describe "GET /api/notifications" do
    it "returns only the current profile's notifications, newest first" do
      create(:notification, user: profile, title: "older", created_at: 1.day.ago)
      newer = create(:notification, user: profile, title: "newer")
      create(:notification) # someone else's

      get "/api/notifications", headers: auth_headers_for(profile)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.size).to eq(2)
      expect(body.first["id"]).to eq(newer.id)
      expect(body.first["unread"]).to be true
    end
  end

  describe "POST /api/notifications/:id/read" do
    it "marks a notification read" do
      notification = create(:notification, user: profile)

      post "/api/notifications/#{notification.id}/read", headers: auth_headers_for(profile)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["unread"]).to be false
      expect(notification.reload.read_at).to be_present
    end

    it "404s for someone else's notification" do
      other_notification = create(:notification)

      post "/api/notifications/#{other_notification.id}/read", headers: auth_headers_for(profile)

      expect(response).to have_http_status(:not_found)
    end
  end
end
