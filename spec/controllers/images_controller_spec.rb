require 'rails_helper'

RSpec.describe ImagesController, type: :controller do
  describe 'GET #index' do
    it 'assigns all images to @images' do
      images = create_list(:image, 3)
      get :index
      expect(assigns(:images)).to match_array(images)
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    let(:image) { create(:image) }

    it 'assigns the requested image to @image' do
      get :show, params: { id: image.id }
      expect(assigns(:image)).to eq(image)
    end

    it 'renders the show template' do
      get :show, params: { id: image.id }
      expect(response).to render_template(:show)
    end

    it 'assigns user count message' do
      # Stub Redis call
      allow(REDIS).to receive(:get).with("user_count_#{image.id}").and_return('{"user_count": 3}')

      get :show, params: { id: image.id }
      expect(assigns(:user_count_msg)).to eq('3 users are currently viewing this image.')
    end
  end

  describe 'GET #new' do
    it 'renders the new template' do
      get :new
      expect(response).to render_template :new
    end

    it 'assigns a new Image to @image' do
      get :new
      expect(assigns(:image)).to be_a_new(Image)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new image' do
        expect {
          post :create, params: { image: attributes_for(:image) }
        }.to change(Image, :count).by(1)
      end

      it 'redirects to images#index' do
        post :create, params: { image: attributes_for(:image) }
        expect(response).to redirect_to(images_path)
      end
    end

    context 'with invalid attributes' do
      it 'does not create a new image' do
        expect {
          post :create, params: { image: attributes_for(:image, title: nil) }
        }.not_to change(Image, :count)
      end

      it 're-renders the new template' do
        post :create, params: { image: attributes_for(:image, title: nil) }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:image) { create(:image) }

    it 'destroys the requested image' do
      expect {
        delete :destroy, params: { id: image.id }
      }.to change(Image, :count).by(-1)
    end

    it 'redirects to images#index' do
      delete :destroy, params: { id: image.id }
      expect(response).to redirect_to(images_path)
    end
  end

  describe 'GET #images_json' do
    it 'returns JSON data containing all images' do
      images = FactoryBot.create_list(:image, 3)
      get :images_json, xhr: true
      expect(JSON.parse(response.body)).to eq(images.as_json)
    end
  end

  describe '#verify_ajax_request' do
    context 'when the request is an XHR (Ajax) request' do
      it 'does not return a forbidden response' do
        get :images_json, xhr: true
        expect(response).not_to have_http_status(:forbidden)
      end
    end

    context 'when the request is not an XHR (Ajax) request' do
      it 'returns a forbidden response' do
        get :images_json
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe '#user_count' do
    let(:image_id) { 1 }
    let(:user_count) { 10 }

    before do
      allow(REDIS).to receive(:get).with("user_count_#{image_id}").and_return({ user_count: user_count }.to_json)
    end

    it 'returns a successful JSON response' do
      get :user_count, params: { id: image_id }
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include('application/json')
    end

    it 'returns the correct user count' do
      get :user_count, params: { id: image_id }
      json_response = JSON.parse(response.body)
      expect(json_response['user_count']).to eq(user_count)
    end
  end
end