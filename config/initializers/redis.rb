require 'redis' unless defined? Redis

redis_config = YAML.load_file(Rails.root + 'config/redis.yml')[Rails.env] || {}

begin
  RedisRecord.REDIS = Redis.new redis_config
rescue => e
  LOGGER.error "#{e.class.name}: #{e.message}"
  LOGGER.warn "couldn't load redis, this could be common in precompilation stage"
end
