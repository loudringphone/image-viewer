require 'rails_helper'

RSpec.describe 'images/new', type: :feature, js: true do
  it 'renders error messages if image title is too long' do
    visit new_image_path
    fill_in 'Title', with: '1234567890123456789012345678901'
    fill_in 'Description', with: '123'
    attach_file('image-attachment', Rails.root.join('spec/fixtures/Image.jpg'))
    expect(page).to have_button('Save', disabled: false)
    click_button('Save')

    expect(page).to have_content('Title is too long (maximum is 30 characters)')
  end

  it 'renders error messages if image title is not filled' do
    visit new_image_path
    fill_in 'Title', with: ''
    attach_file('image-attachment', Rails.root.join('spec/fixtures/Image.jpg'))
    expect(page).to have_button('Save', disabled: true)
  end

  it 'renders error messages if image is not attached' do
    visit new_image_path
    fill_in 'Title', with: 'Example'
    expect(page).to have_button('Save', disabled: true)
  end
end