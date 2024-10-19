# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require "faker"

User.destroy_all
users_data = [
  { email: 'valasek@gmail.com', password: 'valasek', password_confirmation: 'valasek' },
  { email: 'another@gmail.com', password: 'another.user', password_confirmation: 'another.user' }
]

User.create! users_data
user_ids = User.ids

puts "Created #{User.count} sample users successfully!"

Client.destroy_all
1.times do |i|
  Client.create!(
    user_id: user_ids.sample,  # having all the same coach i + 1
    name: Faker::Name.name,
    email: Faker::Internet.email,
    phone: Faker::PhoneNumber.phone_number,
    notes: Faker::Lorem.paragraph(sentence_count: 12),
    created_at: Faker::Time.between(from: 2.years.ago, to: Time.now),
    updated_at: Faker::Time.between(from: 1.year.ago, to: Time.now)
  )
end

puts "Created #{Client.count} sample clients successfully!"
