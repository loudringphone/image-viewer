class ImagesController < ApplicationController
  before_action :verify_ajax_request, only: [:json]
  skip_before_action :verify_authenticity_token, only: [:destroy, :show]

  def index
    broadcast_unsubscribe_message()
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
      # ActionCable.server.broadcast("visitor_channel_#{params[:id]}", {msg: "Visitor count updated #{params[:id]}"})
      return if previous_path === "/images/new"
    end
    image_id = params[:id]
    user_count_json = REDIS.get("user_count_#{params[:id]}")
    user_count_array = JSON.parse(user_count_json)
    user_count = Set.new(user_count_array)
    render json: user_count
  end

  def show
    broadcast_unsubscribe_message()
    @image = Image.find(params[:id])
    retrieve_visitor
    @visitor_id = @visitor.id
    ActionCable.server.broadcast("visitor_channel_#{params[:id]}", {visitor_id: @visitor_id, msg: "Someone has entered visitor channel #{params[:id]}"})
    user_count = JSON.parse(REDIS.get("user_count_#{params[:id]}")).to_set
    users = user_count.size
    @user_count_msg = "#{users} #{'user'.pluralize(users)} #{'is'.pluralize(users)} currently viewing this image."
  end

  def new
    broadcast_unsubscribe_message()
    @image = Image.new
  end

  def create
      @image = Image.new(image_params)
      @image.uploaded_time = Time.now
      if @image.save
        REDIS.set("user_count_#{@image.id}", [])
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

  def verify_ajax_request
    return if request.xhr?
    head :forbidden
  end

  def broadcast_unsubscribe_message
    if request.referrer.present?
      referrer = URI(request.referrer)
      previous_path = referrer.path if referrer.path.present?
      if previous_path.match?(%r{^/images/\d+$})
        retrieve_visitor
        visitor_id = @visitor.id
        id = previous_path.split("/").last.to_i
        ActionCable.server.broadcast("visitor_channel_#{id}", { visitor_id:, msg: "Someone has left visitor channel #{id}"})
      end
    end
  end

  def retrieve_visitor
    user_id = cookies.signed[:user_id] || SecureRandom.hex(16)
    cookies.permanent.signed[:user_id] = user_id
    @visitor = Visitor.find_or_initialize_by(cookie: cookies.signed[:user_id])
    @visitor.save
  end
end
