FactoryBot.define do
  factory :notification do
    association :user, factory: :profile
    title { "New comment on your post" }
    body { "A rider replied with a recommendation." }
  end
end
