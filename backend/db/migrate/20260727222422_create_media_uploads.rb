class CreateMediaUploads < ActiveRecord::Migration[8.1]
  # A throwaway anchor row for a single Active Storage attachment — the upload endpoint
  # creates one of these, attaches the file, and returns its public URL. That URL is what
  # actually gets stored (in Post#media_urls, ChatMessage#media_urls, Profile#avatar_url,
  # etc.) — those stay plain string/array columns, not attachments themselves, per
  # docs/02-data-model.md and docs/18-backend-build-plan.md.
  def change
    create_table :media_uploads, id: :uuid do |t|
      t.uuid :uploaded_by, null: false
      t.timestamps
    end

    add_foreign_key :media_uploads, :profiles, column: :uploaded_by
  end
end
