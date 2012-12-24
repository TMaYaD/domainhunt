module RedisRecord::Base
  extend ActiveSupport::Concern

  def save
    run_callbacks :save do
      success = REDIS.multi do
        REDIS.mapped_hmset(key, attributes)
        REDIS.zadd self.class.meta_key(:id), 0, id
        sorted_indices.each do |attr|
          REDIS.zadd self.class.meta_key(attr), attributes[attr.to_s], id
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
      sorted_indices.each do |attr|
        REDIS.zrem self.class.meta_key(attr), id
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
