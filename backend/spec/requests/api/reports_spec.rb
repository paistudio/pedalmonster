require "rails_helper"

RSpec.describe "Api::Reports", type: :request do
  let(:profile) { create(:profile) }

  describe "POST /api/reports" do
    it "creates a general report requiring a description" do
      post "/api/reports", params: { category: "bug", description: "the feed is blank" },
                            headers: auth_headers_for(profile)

      expect(response).to have_http_status(:created)
    end

    it "rejects a general report without a description" do
      post "/api/reports", params: { category: "bug" }, headers: auth_headers_for(profile)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "creates a per-post report with no description required" do
      post_record = create(:post)

      post "/api/reports", params: { post_id: post_record.id, category: "spam" },
                            headers: auth_headers_for(profile)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["post_id"]).to eq(post_record.id)
    end

    it "rejects an unknown category" do
      post "/api/reports", params: { category: "nonsense", description: "x" }, headers: auth_headers_for(profile)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
