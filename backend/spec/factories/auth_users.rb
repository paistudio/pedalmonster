FactoryBot.define do
  # Stands in for a Supabase auth.users row — see app/models/auth/user.rb.
  factory :auth_user, class: "Auth::User" do
    sequence(:email) { |n| "rider#{n}@example.com" }
  end
end
