module RedisRecord::Base
  extend ActiveSupport::Concern

  def save
    run_callbacks :save do
      success = REDIS.multi do
        REDIS.mapped_hmset(key, attributes)

        defined_sorts.each do |name, block|
          score = 0
          if block
            if block.respond_to? :call
              score = block.call self
            else
              score = self.send block
            end
          end

          REDIS.zadd self.class.meta_key(name), score, id
        end

        defined_filters.each do |name, block|
          REDIS.sadd self.class.filter_key(name, block.call(self)), id
        end
      end
      self.persisted = (success.first == "OK")
    end
  end

  alias save! save

  def key
    self.class.key(id)
  end

  def update_attributes(attrs)
    assign_attributes attrs
    save
  end

  def destroy
    success = REDIS.multi do
      REDIS.del key
      defined_sorts.each do |name, _|
        REDIS.zrem self.class.meta_key(name), id
      end
      defined_filters.each do |name, block|
        REDIS.srem self.class.filter_key(name, block.call(self)), id
      end
    end
    success.first == 1 ? self : nil
  end

  included do
    extend ActiveSupport::Callbacks

    define_callbacks :save
    attr_accessor :persisted
  end
end
