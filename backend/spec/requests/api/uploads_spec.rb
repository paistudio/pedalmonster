require "rails_helper"

RSpec.describe "Api::Uploads", type: :request do
  let(:profile) { create(:profile) }

  describe "POST /api/uploads" do
    it "attaches the file and returns a public URL" do
      file = fixture_file_upload("test_photo.jpg", "image/jpeg")

      post "/api/uploads", params: { file: file }, headers: auth_headers_for(profile)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["url"]).to be_present
      expect(MediaUpload.last.file).to be_attached
    end
  end
end
