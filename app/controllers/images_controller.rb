require 'json'

class ImagesController < ApplicationController
  before_action :verify_ajax_request, only: [:images_json]
  skip_before_action :verify_authenticity_token, only: [:destroy, :show]

  rescue_from SQLite3::BusyException do |exception|
    flash[:alert] = "Sorry, the database is currently busy. Please try again later."
  end

  def index
    @images = Image.order(created_at: :desc)
  end

  def show
    image_id = params[:id]
    increment_views(image_id)
    @image = Image.find(image_id)
    user_count_json = REDIS.get("user_count_#{params[:id]}") || {user_count: 0}.to_json
    @user_count = JSON.parse(user_count_json)["user_count"]
    @user_count = 1 if @user_count === 0
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
      REDIS.set("user_count_#{@image.id}", {lock: nil, user_count: 0}.to_json)
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
      ActionCable.server.broadcast("visitor_channel_#{@image.id}", { msg: "Image #{@image.id} has been destroyed."})
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
    user_count_json = REDIS.get("user_count_#{params[:id]}") || {user_count: 0}.to_json
    user_count = JSON.parse(user_count_json)
    render json: user_count
  end

  def increment_views(image_id)
    Image.transaction do
      image = Image.lock.find(image_id)
      image.update!(current_views: image.current_views + 1)
    end
  rescue ActiveRecord::RecordNotFound
  rescue ActiveRecord::Deadlocked
  end

  def decrement_views
    Image.transaction do
      image = Image.lock.find(params[:id])
      image.update!(current_views: image.current_views - 1)
    end
  rescue ActiveRecord::RecordNotFound
  rescue ActiveRecord::Deadlocked
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
