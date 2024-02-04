require 'rails_helper'

RSpec.describe 'images/index', type: :feature, js: true do
  before(:each) do
    create_list(:image, 3)
    visit images_path
  end

  it 'displays a list of images' do
    expect(page).to have_selector('img', count: 3)
  end

  it 'renders the title of each image' do
    Image.all.each do |image|
      expect(page).to have_content(image.title)
    end
  end

  it 'renders a link to view each image' do
    Image.all.each do |image|
      expect(page).to have_link(image.title, href: image_path(image))
    end
  end
end