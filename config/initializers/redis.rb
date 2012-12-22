require 'redis' unless defined? Redis
begin
  REDIS ||= Redis.new
rescue => e
  LOGGER.error "#{e.class.name}: #{e.message}"
  LOGGER.warn "couldn't load redis, this could be common in precompilation stage"
end
