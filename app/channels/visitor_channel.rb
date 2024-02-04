class VisitorChannel < ApplicationCable::Channel
  def subscribed
    stream_from "visitor_channel_#{params[:id]}"
    update_user_count(1)
  end

  def unsubscribed
    stop_stream_from "visitor_channel_#{params[:id]}"
    update_user_count(-1)
  end

  private

  def update_user_count(change)
    user_count_json = REDIS.get("user_count_#{params[:id]}") || {user_count: 0}.to_json
    user_count = eval(user_count_json)[:user_count]
    user_count += change
    REDIS.set("user_count_#{params[:id]}", {user_count: }.to_json)
    ActionCable.server.broadcast("visitor_channel_#{params[:id]}", { msg: "#{user_count}(#{change}) #{user_count == 1 ? 'user' : 'users'} on Visitor Channel #{params[:id]}"})
  end
end
