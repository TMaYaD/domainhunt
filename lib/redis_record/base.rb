module RedisRecord::Base
  extend ActiveSupport::Concern

  included do
    extend ActiveSupport::Callbacks

    define_callbacks :save
    attr_accessor :persisted
  end

  def save
    run_callbacks :save do
      old_dog = self.class.find(id)
      success = REDIS.multi do
        REDIS.mapped_hmset(key, attributes)

        if old_dog
          old_dog.remove_from_sort_lists
          old_dog.remove_from_filter_lists
        end
        add_to_sort_lists
        add_to_filter_lists

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

      remove_from_sort_lists
      remove_from_filter_lists
    end
    success.first == 1 ? self : nil
  end

protected
  def add_to_sort_lists
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
  end

  def remove_from_sort_lists
    defined_sorts.each do |name, _|
      REDIS.zrem self.class.meta_key(name), id
    end
  end

  def add_to_filter_lists
    defined_filters.each do |name, block|
      REDIS.sadd filter_key(name, block), id
    end
  end

  def remove_from_filter_lists
    defined_filters.each do |name, block|
      REDIS.srem filter_key(name, block), id
    end
  end

private
  def filter_key(name, block)
    value = block ? block.call(self) : self.send(name)
    REDIS.zincrby self.class.filter_key('_Values', name), 1, value
    self.class.filter_key(name, value)
  end

end
