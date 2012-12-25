module RedisRecord::Base
  module ClassMethods

    def scoped(*args)
      RedisScope.new self, *args
    end

    delegate :filter, :sort, :min, :max, :limit, :offset, :to => :scoped
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

    def create_filter(name, &block)
      defined_filters[name] = block
    end

    def sortable(name, &block)
      defined_sorts[name] = block
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

