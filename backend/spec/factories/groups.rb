FactoryBot.define do
  factory :group do
    sequence(:name) { |n| "Group #{n}" }
    description { "A test group" }
    association :owner, factory: :profile
  end
end
