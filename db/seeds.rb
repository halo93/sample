# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create!(name:  "Example User",
             email: "example@railstutorial.org",
             password:              "foobar",
             password_confirmation: "foobar",
             admin:     true,
             activated: true,
             activated_at: Time.zone.now)

99.times do |n|
  name  = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password,
               activated: true,
               activated_at: Time.zone.now)
end
users = User.order(:created_at).take 6
20.times do
  content = Faker::Lorem.paragraphs 3, true
  image = File.open(Dir.glob(File.join(Rails.root, "app/assets/images", "sample.jpg")).sample)
  users.each {|user| user.microposts.create! content: content, picture: image}
end

users = User.all
user  = users.first
following = users[2..20]
followers = users[3..20]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }

users_10 = users.limit 10
users_10.each do |user|
  my_microposts = user.microposts
  user.followers.each do |follower|
    content = Faker::Lorem.sentence 3
    my_microposts.each do |micropost|
      follower.comments.create! content: content, micropost_id: micropost.id
    end
  end
end
