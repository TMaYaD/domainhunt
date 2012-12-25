module RedisRecord::Base
  module ClassMethods

    def scoped(*args)
      RedisScope.new self, *args
    end

    delegate :filter, :limit, :offset, :to => :scoped
    delegate :all, :count, :first, :last, :to => :scoped

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


    def find_or_initialize_by_id(id)
      find(id) || self.new(:id => id)
    end

    def search_by_range_on(attr)
      self.sorted_indices.push attr
      define_singleton_method "find_ids_by_#{attr}" do |min, max|
        REDIS.zrangebyscore meta_key(attr), min, max
      end

      define_singleton_method "filter_ids_by_#{attr}" do |offset_begin, offset_end|
        REDIS.zrange meta_key(attr), offset_begin, offset_end
      end
    end

    def create_filter(name, &block)
      defined_filters[name] = block
    end

    def meta_key(attr)
      ['Meta', model_name, attr].join ':'
    end

    def filter_key(name, value)
      meta_key "Filter:#{name}:#{value}"
    end

    def key(id)
      [model_name, id].join ':'
    end
  end
end

