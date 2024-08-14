FactoryBot.define do
  factory :user, class: "User" do
    name { Faker::Name.name }
    sequence(:email) { |n| "test-#{n}@gmail.com" }
    password { "123456Aa" }
    password_confirmation { "123456Aa"}
  end
end
