FactoryBot.define do
  factory :city do
    sequence(:name) { |n| "City #{n}" }
    province { "Test Province" }
    lat { -6.9 }
    lng { 107.6 }
  end
end
