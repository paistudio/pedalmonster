require "rails_helper"

RSpec.describe MediaUpload, type: :model do
  before do
    # Normally set by Api::BaseController's before_action — needed here since these are
    # model specs, not request specs, to generate a Disk-service blob URL at all.
    ActiveStorage::Current.url_options = { host: "example.com", port: nil, protocol: "https" }
  end

  describe "#public_url" do
    it "uses the blob's own url for a non-Supabase service (e.g. local disk in dev/test)" do
      upload = create(:media_upload)
      upload.file.attach(fixture_file_upload("test_photo.jpg", "image/jpeg"))

      # blob.url signs a fresh expiry each call, so two calls won't be byte-identical —
      # assert it's the Disk service's signed-URL shape, not exact string equality.
      expect(upload.public_url).to match(%r{\Ahttps://example\.com/rails/active_storage/disk/.+/test_photo\.jpg\z})
    end

    it "builds Supabase's native public object URL when the file is on the supabase service" do
      upload = create(:media_upload)
      upload.file.attach(fixture_file_upload("test_photo.jpg", "image/jpeg"))
      blob = upload.file.blob
      allow(blob).to receive(:service_name).and_return("supabase")
      allow(upload.file).to receive(:blob).and_return(blob)

      with_env("SUPABASE_URL" => "https://xbhbuacunshbggdylhzw.supabase.co", "SUPABASE_STORAGE_BUCKET" => "media") do
        expect(upload.public_url).to eq(
          "https://xbhbuacunshbggdylhzw.supabase.co/storage/v1/object/public/media/#{blob.key}"
        )
      end
    end
  end
end
