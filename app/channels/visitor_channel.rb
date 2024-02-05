require 'securerandom'
require 'json'

class VisitorChannel < ApplicationCable::Channel
  def subscribed
    stream_from "visitor_channel_#{params[:id]}"
    update_user_counts(1)
  end

  def unsubscribed
    stop_stream_from "visitor_channel_#{params[:id]}"
    update_user_counts(-1)
  end

  private

  def update_user_counts(change)
    update_PostgreSQL_user_count(change)
    update_Redis_user_count(change)
  rescue => e
    puts "Error updating user counts: #{e.message}"
    update_Redis_user_count(change)
  end

  def update_PostgreSQL_user_count(change)
    Image.transaction do
      image = Image.lock.find(params[:id])
      image.update!(current_views: image.current_views + change)
    end
  end

  def update_Redis_user_count(change)
    if change == 1
      user_count = REDIS.incr("user_count_#{params[:id]}")
    else
      user_count = REDIS.decr("user_count_#{params[:id]}")
    end
    ActionCable.server.broadcast("visitor_channel_#{params[:id]}", { msg: "#{user_count}(#{change}) #{user_count == 1 ? 'user' : 'users'} on Visitor Channel #{params[:id]}"})
  end

  # def update_Redis_user_count(change)
  #   new_lock = SecureRandom.uuid
  #   user_count_hash = locking(new_lock)
  #   REDIS.multi do |multi|
  #     user_count = user_count_hash['user_count']
  #     user_count += change
  #     user_count_hash = {'lock': nil, 'user_count': user_count}
  #     multi.set("user_count_#{params[:id]}", user_count_hash.to_json)
  #     ActionCable.server.broadcast("visitor_channel_#{params[:id]}", { msg: "#{user_count}(#{change}) #{user_count == 1 ? 'user' : 'users'} on Visitor Channel #{params[:id]}"})
  #   end
  # end

  # def locking(new_lock)
  #   current_lock = new_lock
  #   user_count_hash = nil
  #   retries = 30
  #   begin
  #     until !current_lock || retries <= 0
  #       user_count_json = REDIS.get("user_count_#{params[:id]}") || {'lock': nil, 'user_count': 0}.to_json
  #       user_count_hash = JSON.parse(user_count_json)
  #       current_lock = user_count_hash["lock"]
  #       retries -= 1
  #     end
  #     if retries <= 0
  #       raise "Failed to acquire lock after multiple retries for user_count_#{params[:id]}"
  #     end
  #     user_count_hash["lock"] = new_lock
  #     REDIS.set("user_count_#{params[:id]}", user_count_hash.to_json)

  #     user_count_hash = JSON.parse(REDIS.get("user_count_#{params[:id]}"))
  #     if user_count_hash["lock"] != new_lock
  #       locking(new_lock)
  #     else
  #       user_count_hash
  #     end
  #   rescue StandardError => e
  #     puts "Error occurred: #{e.message}"
  #     user_count_hash = {'lock': nil, 'user_count': 99999}
  #   end
  # end
end
