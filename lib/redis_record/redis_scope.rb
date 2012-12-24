class RedisScope
  def initialize(model, *args)
    @model = model
  end

  # Modifiers
  # always returns self
  def limit(n)
    @limit = n
    self
  end

  # Executors
  def count
    total_records = REDIS.zcount @model.meta_key(:id), '-inf', '+inf'
    return total_records unless @limit

    [total_records, @limit].min
  end

  def all
    ids.map {|id| @model.find id}
  end

private
  def ids
    REDIS.zrange @model.meta_key(:id), 0, @limit - 1
  end
end
