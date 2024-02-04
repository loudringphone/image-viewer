require 'rails_helper'

RSpec.describe 'images/index', type: :feature, js: true do
  before do
    create_list(:image, 3)
  end

  it 'displays a list of images' do
    visit images_path

    expect(page).to have_selector('img', count: 3)
    Image.all.each do |image|
      expect(page).to have_content(image.title)
      expect(page).to have_link(image.title, href: image_path(image))
    end
  end
end