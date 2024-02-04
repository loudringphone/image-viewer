require 'rails_helper'
require 'selenium-webdriver'


RSpec.describe 'images/show', type: :feature, js: true do
  let(:image) { create(:image) }

  it 'displays the image details with cookies' do
  visit image_path(image)

    expect(page).to have_content(image.title)
    expect(page).to have_selector('img')
  end
end