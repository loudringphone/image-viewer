class ImagesController < ApplicationController
  before_action :retrieve_visitor, only: [:show]

  def index
    @images = Image.all
  end

  def show
    @image = Image.find(params[:id])
    visitor_count = Visitor.viewed_image_within_last_minute(params[:id]).count
    if visitor_count % 2 == 0
      @visitor_msg = "#{visitor_count} visitors are currently viewing this image."
    else
      @visitor_msg = "#{visitor_count} visitor is currently viewing this image."
    end
  end

  def new
      @image = Image.new
  end

  def create
      @image = Image.new(image_params)
      @image.uploaded_time = Time.now
      if @image.save
        redirect_to images_path, notice: "#{@image.title} was successfully uploaded."
      else
        render :new, status: :unprocessable_entity
      end
  end

  def destroy
    @image = Image.find(params[:id])
    @image.destroy
    redirect_to images_path, notice:  "#{@image.title} was successfully deleted."
  end

  private

  def image_params
    params.require(:image).permit(:title, :attachment)
  end

  def retrieve_visitor
    user_id = cookies.signed[:user_id] || SecureRandom.hex(16)
    cookies.permanent.signed[:user_id] = user_id
    @visitor = Visitor.find_or_initialize_by(cookie: cookies.signed[:user_id])
    @visitor.image_last_viewed = params[:id]
    @visitor.last_seen_at = Time.current
    @visitor.save
  end
end
