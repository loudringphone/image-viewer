require 'redis'

# Create a Redis client instance
REDIS = Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379/0')

keys_to_delete = REDIS.keys("user_count_*")
keys_to_delete.each do |key|
  REDIS.del(key)
end