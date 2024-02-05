require 'rails_helper'
require 'selenium-webdriver'

RSpec.describe 'images/show', type: :feature, js: true do
  let!(:images) { create_list(:image, 5) } # Create 5 images using FactoryBot

  it 'displays the image details with correct next and prev buttons on first image' do
    visit image_path(images.first)
    expect(page).to have_content(images.first.title)
    expect(page).to have_selector('img')
    expect(page).to have_content('Redis: 1')
    expect(page).to have_content('PostgreSQL: 1')
    expect(page).to have_selector('#next')
    expect(page).not_to have_selector('#previous')
  end

  it 'displays the image details with correct next and prev buttons on last image' do
    visit image_path(images.last)
    expect(page).to have_selector('#previous')
    expect(page).not_to have_selector('#next')
  end

  it 'displays the image details with correct next and prev buttons on a middle image' do
    visit image_path(images[3])
    expect(page).to have_selector('#previous')
    expect(page).to have_selector('#next')
    images.last.destroy
    page.evaluate_script('window.location.reload()')
    expect(page).not_to have_selector('#next')
  end
end
