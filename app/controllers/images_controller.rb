require 'json'

class ImagesController < ApplicationController
  before_action :verify_ajax_request, only: [:images_json]
  skip_before_action :verify_authenticity_token, only: [:destroy, :show]

  def index
    @images = Image.order(created_at: :desc)
  end

  def show
    image_id = params[:id]
    @image = Image.find(image_id)
    @user_count = REDIS.get("user_count_#{params[:id]}").to_i
    @previous_image = Image.previous_image(@image.created_at)
    @next_image = Image.next_image(@image.created_at)

  rescue ActiveRecord::RecordNotFound
    flash[:notice] = "Image with ID #{params[:id]} not found"
    redirect_to images_path
  end

  def new
    @image = Image.new
  end

  def create
    @image = Image.new(image_params)
    if @image.save
      previous_image = Image.previous_image(@image.created_at)
      ActionCable.server.broadcast("visitor_channel_#{previous_image.id}", { code: "next", img_id: @image.id, msg: "Next image #{@image.id} has been created."}) if previous_image
      REDIS.set("user_count_#{@image.id}", 0)
      # REDIS.set("user_count_#{@image.id}", {lock: nil, user_count: 0}.to_json)
      ActionCable.server.broadcast('image_channel', { msg: "#{@image.title} has been created."})
      redirect_to images_path, notice: "#{@image.title} was successfully uploaded."
    else
      @image.title = nil
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @image = Image.find(params[:id])
    if @image.destroy
      ActionCable.server.broadcast('image_channel', { msg: "#{@image.title} has been destroyed."})
      ActionCable.server.broadcast("visitor_channel_#{@image.id}", { code: "destroy", msg: "Image #{@image.id} has been destroyed."})
      previous_image = Image.previous_image(@image.created_at)
      if previous_image
        new_next_image = Image.next_image(previous_image.created_at)
        ActionCable.server.broadcast("visitor_channel_#{previous_image.id}", { code: "next", img_id: new_next_image&.id, msg: "Next image #{@image.id} has been destroyed."})
      end
      next_image = Image.next_image(@image.created_at)
      if next_image
        new_previous_image = Image.previous_image(next_image.created_at)
        ActionCable.server.broadcast("visitor_channel_#{next_image.id}", { code: "previous", img_id: new_previous_image&.id,msg: "Previous image #{@image.id} has been destroyed."})
      end

    end
    redirect_to images_path, notice:  "#{@image.title} was successfully deleted."
  end

  def images_json
    @images = Image.all
    render json: @images
  end

  def user_count
    image_id = params[:id]
    user_count = REDIS.get("user_count_#{params[:id]}") || 0

    render json: user_count
  end

  private

  def image_params
    params.require(:image).permit(:title, :attachment, :description, :current_views)
  end

  def verify_ajax_request
    return if request.xhr?
    head :forbidden
  end
end
