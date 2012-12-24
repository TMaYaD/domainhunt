module RedisRecord::Base
  module ClassMethods

    def scoped(*args)
      RedisScope.new self, *args
    end

    delegate :limit, :to => :scoped

    def create(*args)
      new(*args).save
    end

    def find(id)
      find_by_key key id
    end

    def find_by_key(key)
      attributes = REDIS.mapped_hmget(key, *attribute_names)
      attributes['id'] && self.new(attributes).tap { |r| r.persisted = true }
    end

    def all
      filter
    end

    def filter(offset=0, length= -1 - offset)
      filter_ids(offset, offset + length).map { |id| find id }
    end

    def filter_ids(offset_begin, offset_end)
      REDIS.zrange meta_key(:id), offset_begin, offset_end
    end

    def count
      REDIS.zcount(meta_key(:id), '-inf', '+inf')
    end

    delegate :first, :last, :to => :all

    def find_or_initialize_by_id(id)
      find(id) || self.new(:id => id)
    end

    def search_by_range_on(attr)
      self.sorted_indices += [attr]
      define_singleton_method "find_ids_by_#{attr}" do |min, max|
        REDIS.zrangebyscore meta_key(attr), min, max
      end

      define_singleton_method "filter_ids_by_#{attr}" do |offset_begin, offset_end|
        REDIS.zrange meta_key(attr), offset_begin, offset_end
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
end

