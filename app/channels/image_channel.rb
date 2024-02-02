class ImageChannel < ApplicationCable::Channel
  def subscribed
    stream_from "image_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
