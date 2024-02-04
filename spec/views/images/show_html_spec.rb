require 'rails_helper'
require 'selenium-webdriver'


RSpec.describe 'images/show', type: :feature, js: true do
  let(:image) { create(:image) }

  it 'displays the image details' do
  visit image_path(image)
    expect(page).to have_content(image.title)
    expect(page).to have_selector('img')
    expect(page).to have_content('1 user is currently viewing this image.')
  end
end