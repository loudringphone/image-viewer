class VisitorChannel < ApplicationCable::Channel
  def subscribed
    update_user_count(1)
    stream_from "visitor_channel_#{params[:id]}"
  end

  def unsubscribed
    update_user_count(-1)
  end

  private

  def update_user_count(change)
    user_count = REDIS.get("user_count_#{params[:id]}").to_i
    user_count += change
    REDIS.set("user_count_#{params[:id]}", user_count)
    ActionCable.server.broadcast("visitor_channel_#{params[:id]}", { user_count: })
  end
end
