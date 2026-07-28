class MediaUpload < ApplicationRecord
  belongs_to :uploader, class_name: "Profile", foreign_key: :uploaded_by, inverse_of: false
  has_one_attached :file

  # Supabase Storage's S3-compatible gateway (what ActiveStorage's default blob.url points at)
  # requires signed (SigV4) requests even for GET — it doesn't serve anonymous reads, so that
  # URL 403s even on a public bucket. Supabase's own REST API serves public objects at a
  # different, actually-public path — use that instead when the file lives on the `supabase`
  # service. Confirmed by hand against the real project; see docs/18-backend-build-plan.md.
  def public_url
    blob = file.blob
    if blob.service_name.to_s == "supabase"
      "#{ENV.fetch('SUPABASE_URL')}/storage/v1/object/public/#{ENV.fetch('SUPABASE_STORAGE_BUCKET')}/#{blob.key}"
    else
      blob.url
    end
  end
end
