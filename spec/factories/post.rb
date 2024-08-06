FactoryBot.define do
  factory :post, class: "Post" do
    user
    title { "Title example" }
    content { "Content example" }
    status { "public" }
  end
end
