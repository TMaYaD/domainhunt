RSpec.configure do |c|
  c.before(:each) do |example|
    REDIS.flushall
  end
end
