class VisitorChannel < ApplicationCable::Channel
  def subscribed
    stream_from "visitor_channel_#{params[:id]}"
    update_user_count(connection.current_user_cookie, true)
  end

  def unsubscribed
    stop_stream_from "visitor_channel_#{params[:id]}"
    update_user_count(connection.current_user_cookie, false)
  end

  private

  def update_user_count(cookie, change)
    user_set = JSON.parse(REDIS.get("user_count_#{params[:id]}")).to_set
    if change
      user_set.add(cookie)
    else
      user_set.delete(cookie)
    end
    user_set = user_set.to_a
    REDIS.set("user_count_#{params[:id]}", user_set)
    user_count = user_set.size
    ActionCable.server.broadcast("visitor_channel_#{params[:id]}", { msg: "#{user_count}(#{change}) #{user_count == 1 ? 'user' : 'users'} on Visitor Channel #{params[:id]}"})
  end
end
