require 'faker'

Image.destroy_all

# Create images
images = [
  { title: 'Image 1', attachment: File.open(File.join(Rails.root, 'app', 'assets', 'images', 'image1.jpg')), description: Faker::Lorem.sentence(word_count: 15) },
  { title: 'Image 2', attachment: File.open(File.join(Rails.root, 'app', 'assets', 'images', 'image2.jpg')), description: Faker::Lorem.sentence(word_count: 15) },
  { title: 'Image 3', attachment: File.open(File.join(Rails.root, 'app', 'assets', 'images', 'image3.jpg')), description: Faker::Lorem.sentence(word_count: 15) },
  { title: 'Image 4', attachment: File.open(File.join(Rails.root, 'app', 'assets', 'images', 'image4.jpg')), description: Faker::Lorem.sentence(word_count: 15) },
  { title: 'Image 5', attachment: File.open(File.join(Rails.root, 'app', 'assets', 'images', 'image5.jpg')), description: Faker::Lorem.sentence(word_count: 15) }
]

# Seed images
images.each do |image_params|
  image = Image.new(image_params)
  image.attachment = image_params[:attachment] # Assign attachment
  image.save!
end

puts "#{ Image.count } seed images have been created"









# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
