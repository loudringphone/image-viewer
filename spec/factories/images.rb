require 'faker'

FactoryBot.define do
  factory :image do
    title { Faker::Lorem.sentence(word_count: 2) }
    description { Faker::Lorem.sentence(word_count: 25) }
    attachment { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/Image.jpg")) }
  end
end