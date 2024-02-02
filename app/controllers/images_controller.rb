class ImagesController < ApplicationController
  # before_action :retrieve_visitor, only: [:show]

  def index
    @images = Image.all
  end

  def json
    @images = Image.all
    render json: @images
  end

  def visitor_count
    image_id = params[:id]
    user_count = REDIS.get("user_count_#{image_id}").to_i
    render json: { user_count: user_count }
  end

  def show
    @image = Image.find(params[:id])
    ActionCable.server.broadcast("visitor_channel_#{params[:id]}", {msg: 'A new player has entered the game!'})
    user_count = REDIS.get("user_count_#{params[:id]}").to_i
    @user_count_msg = "#{user_count} #{'user'.pluralize(user_count)} #{'is'.pluralize(user_count)} currently viewing this image."
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

  # def retrieve_visitor
  #   user_id = cookies.signed[:user_id] || SecureRandom.hex(16)
  #   cookies.permanent.signed[:user_id] = user_id
  #   @visitor = Visitor.find_or_initialize_by(cookie: cookies.signed[:user_id])
  #   @visitor.save
  # end
end
