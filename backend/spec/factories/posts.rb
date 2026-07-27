FactoryBot.define do
  factory :post do
    association :author, factory: :profile
    type { "community_post" }
    description { "A test post" }

    trait :listing do
      type { "listing" }
      title { "Test bike" }
      type_data { { "category" => "bike", "condition" => "used", "price" => 1_000_000, "status" => "available" } }
    end

    trait :comment do
      type { "comment" }
      description { "A test comment" }
      association :parent, factory: :post
    end
  end
end
