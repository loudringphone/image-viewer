class HomeController < ApplicationController
  def index
    render 'pages/home'
  end

  def upload_image
    uploaded_file = params[:file]
    if uploaded_file.content_type.start_with?('image/')
      # Process the image upload
    else
      flash[:error] = 'Please upload only image files.'
      redirect_to action: 'upload_file'
    end
  end
end
