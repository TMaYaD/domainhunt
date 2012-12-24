RSpec.configure do |c|
  c.before(:each) do |example|
    REDIS.flushdb
  end
end
