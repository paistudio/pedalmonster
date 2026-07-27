FactoryBot.define do
  factory :profile do
    transient do
      auth_user { create(:auth_user) }
    end

    id { auth_user.id }
    sequence(:username) { |n| "rider#{n}" }
    points { 0 }
  end
end
