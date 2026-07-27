module Api
  # A single generic upload endpoint backing every photo-attach flow in the app (post/comment
  # photos, chat photos, avatar) — the frontend uploads a file here first, then includes the
  # returned URL string in media_urls/avatar_url on the actual post/comment/message/profile
  # request. See docs/18-backend-build-plan.md's Active Storage + Supabase Storage wiring.
  class UploadsController < BaseController
    def create
      file = params.require(:file)
      upload = MediaUpload.new(uploaded_by: current_profile.id)
      upload.file.attach(file)

      if upload.save
        render json: { url: upload.file.blob.url }, status: :created
      else
        render json: { errors: upload.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
