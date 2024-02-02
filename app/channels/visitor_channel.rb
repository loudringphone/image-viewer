class VisitorChannel < ApplicationCable::Channel
  def subscribed
    stream_from "visitor_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def received(data)
    ActionCable.server.broadcast "visitor_channel", message: data["message"]
  end
end
