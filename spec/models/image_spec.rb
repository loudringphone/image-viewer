require 'rails_helper'

RSpec.describe Image, type: :model do
  it 'has a valid factory' do
    image = create(:image)
    expect(image).to be_valid
  end
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_most(30) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:attachment) }
  end
end
