class ImagesController < ApplicationController
  before_action :retrieve_visitor, only: [:show]

  def index
    @images = Image.all
  end

  def json
    @images = Image.all
    render json: @images
  end

  def show
    @image = Image.find(params[:id])
    visitor_count = Visitor.viewed_image_within_5_seconds(params[:id]).count
    ActionCable.server.broadcast('visitor_channel', { visitor_count: })
    @visitor_msg = "#{visitor_count} #{'visitor'.pluralize(visitor_count)} #{'is'.pluralize(visitor_count)} currently viewing this image."
  end

  def visitor_count
    retrieve_visitor()
    visitor_count = Visitor.viewed_image_within_5_seconds(params[:id]).count
    visitor_count_msg = "#{visitor_count} #{'visitor'.pluralize(visitor_count)} #{'is'.pluralize(visitor_count)} currently viewing this image."
    render json: { visitor_count_msg: }
  end

  def new
      @image = Image.new
  end

  def create
      @image = Image.new(image_params)
      @image.uploaded_time = Time.now
      if @image.save
        ActionCable.server.broadcast('image_channel', { msg: 'An image has been created.'})
        redirect_to images_path, notice: "#{@image.title} was successfully uploaded."
      else
        render :new, status: :unprocessable_entity
      end
  end

  def destroy
    @image = Image.find(params[:id])
    if @image.destroy
      ActionCable.server.broadcast('image_channel', { msg: 'An image has been destroyed.'})
    end
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
