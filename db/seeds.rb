User.destroy_all
Post.destroy_all

10.times do |n|
  name = Faker::Name.name
  email = "example-#{n+1}@gmail.com"
  password = "password1A"
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password)
end

users = User.order(:created_at).take(6)

30.times do |i|
  title = Faker::Lorem.sentence(word_count: 5)
  content = Faker::Lorem.sentence(word_count: 10)
  users.each{|user| user.posts.create!(title: title, content: content, status: [0, 1].sample)}
end
