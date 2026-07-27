class MediaUpload < ApplicationRecord
  belongs_to :uploader, class_name: "Profile", foreign_key: :uploaded_by, inverse_of: false
  has_one_attached :file
end
