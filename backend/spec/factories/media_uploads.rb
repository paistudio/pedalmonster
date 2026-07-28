FactoryBot.define do
  factory :media_upload do
    association :uploader, factory: :profile
  end
end
