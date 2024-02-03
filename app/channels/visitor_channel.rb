class VisitorChannel < ApplicationCable::Channel
  def subscribed
    stream_from "visitor_channel_#{params[:id]}"
  end

  def unsubscribed
  end

  def received(data)
    case data['action']
    when 'entered'
      entered(data)
    when 'left'
      left(data)
    end
  end

  def entered(data)
    update_user_count(data['data'], true)
  end

  def left(data)
    update_user_count(data['data'], false)
  end

  private

  def update_user_count(visitor_id, change)
    user_set_json = REDIS.get("user_count_#{params[:id]}")
    user_set_array = JSON.parse(user_set_json)
    user_set = Set.new(user_set_array)
    if change
      user_set.add(visitor_id.to_i)
    else
      user_set.delete(visitor_id.to_i)
    end
    user_set = user_set.to_a
    REDIS.set("user_count_#{params[:id]}", user_set)
    ActionCable.server.broadcast("visitor_channel_#{params[:id]}", { msg: "User count changed #{params[:id]}"})
  end
end
