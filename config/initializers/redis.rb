require 'redis'

# Create a Redis client instance
REDIS = Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379/0')

# Clear the Redis db everytime the server is started
REDIS.flushdb