
FactoryBot.define do
  factory :image do
    title { "Example Image" }
    attachment { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/Image.jpg")) }
  end
end