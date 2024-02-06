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
    new_lock = SecureRandom.uuid
    if (locking(new_lock))
      if change == 1
        user_count = REDIS.incr("user_count_#{params[:id]}")
      else
        user_count = REDIS.decr("user_count_#{params[:id]}")
      end
      REDIS.set("user_count_#{params[:id]}_lock", "")
      ActionCable.server.broadcast("visitor_channel_#{params[:id]}", { user_count:, msg: "#{user_count}(#{change}) #{user_count == 1 ? 'user' : 'users'} on Visitor Channel #{params[:id]}"})
    end
  end

  def locking(new_lock)
    current_lock = new_lock
    lock = nil
    retries = 50
    begin
      until current_lock.blank? || retries <= 0
        lock = REDIS.get("user_count_#{params[:id]}_lock")
        current_lock = lock
        retries -= 1

      end

      if retries <= 0
        raise "Failed to acquire lock after multiple retries for user_count_#{params[:id]}"
      end

      REDIS.set("user_count_#{params[:id]}_lock", new_lock)
      lock = REDIS.get("user_count_#{params[:id]}_lock")
      if lock != new_lock
        locking(new_lock)
      else
        return true
      end
    rescue StandardError => e
      puts "Error occurred: #{e.message}"
      false
    end
  end
end
