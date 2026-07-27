require "rails_helper"

RSpec.describe "Api::Cities", type: :request do
  describe "GET /api/cities" do
    it "rejects requests without a token" do
      get "/api/cities"
      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects requests with a garbage token" do
      get "/api/cities", headers: { "Authorization" => "Bearer not-a-real-token" }
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns cities for an authenticated request" do
      profile = create(:profile)
      create_list(:city, 3)

      get "/api/cities", headers: auth_headers_for(profile)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(3)
    end
  end
end
