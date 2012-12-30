RSpec.configure do |c|
  c.before(:each) do |example|
    RedisRecord.REDIS.flushdb
  end
end
