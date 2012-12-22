module RedisRecord::Base
  extend ActiveSupport::Concern

  def save
    run_callbacks :save do
      success = REDIS.multi do
        REDIS.mapped_hmset(key, attributes)
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

  module ClassMethods
    def find(id)
      find_by_key key id
    end

    def find_by_key(key)
      attributes = REDIS.mapped_hmget(key, *attribute_names)
      attributes['id'] && self.new(attributes).tap { |r| r.persisted = true }
    end

    def all
      REDIS.keys("#{model_name}:*").map { |key| find_by_key key }
    end

    delegate :count, :first, :last, :to => :all

    def find_or_initialize_by_id(id)
      find(id) || self.new(:id => id)
    end

    def search_by_range_on(attr)
      self.sorted_indices += [attr]
      define_singleton_method "find_ids_by_#{attr}" do |min, max|
        REDIS.zrangebyscore(meta_key(attr), min, max)
      end
    end

    def find_ids_and_sort_by(attr, options)
      REDIS.zrange(meta_key(attr), *options[:limit])
    end

    def find_ids_and_reverse_sort_by(attr, options)
      REDIS.zrevrange(meta_key(attr), *options[:limit])
    end

    def meta_key(attr)
      ['Meta', model_name, attr].join ':'
    end

    def key(id)
      [model_name, id].join ':'
    end
  end

  included do
    extend ActiveSupport::Callbacks

    define_callbacks :save
    attr_accessor :persisted
  end
end
