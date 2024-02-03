class ImagesController < ApplicationController
  before_action :verify_ajax_request, only: [:json]
  skip_before_action :verify_authenticity_token, only: [:destroy, :show]

  def index
    @images = Image.all
  end

  def json
    @images = Image.all
    render json: @images
  end

  def visitor_count
    if request.referrer.present?
      referrer = URI(request.referrer)
      previous_path = referrer.path if referrer.path.present?
      return if previous_path === "/images/new"
    end
    image_id = params[:id]
    user_count = REDIS.get("user_count_#{params[:id]}")
    render json: user_count
  end

  def show
    @image = Image.find(params[:id])
    user_count = JSON.parse(REDIS.get("user_count_#{params[:id]}")).to_set
    users = user_count.size
    @user_count_msg = "#{users} #{'user'.pluralize(users)} #{'is'.pluralize(users)} currently viewing this image."
  end

  def new
    @image = Image.new
  end

  def create
      @image = Image.new(image_params)
      @image.uploaded_time = Time.now
      if @image.save
        REDIS.set("user_count_#{@image.id}", [])
        ActionCable.server.broadcast('image_channel', { msg: "Image #{@image.id} has been created."})
        redirect_to images_path, notice: "#{@image.title} was successfully uploaded."
      else
        @image.title = nil
        render :new, status: :unprocessable_entity
      end
  end

  def destroy
    @image = Image.find(params[:id])
    if @image.destroy
      ActionCable.server.broadcast('image_channel', { msg: "Image #{@image.id} has been destroyed."})
      ActionCable.server.broadcast("visitor_channel_#{@image.id}", { msg: "Image #{@image.id} has been destroyed."})

    end
    redirect_to images_path, notice:  "#{@image.title} was successfully deleted."
  end

  private

  def image_params
    params.require(:image).permit(:title, :attachment)
  end

  def verify_ajax_request
    return if request.xhr?
    head :forbidden
  end
end
