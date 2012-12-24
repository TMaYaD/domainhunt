class RedisScope
  def initialize(model, *args)
    @model = model
    @offset = 0
  end

  # Modifiers
  # always returns self
  def limit(n)
    @limit = n
    self
  end

  def offset(n)
    @offset = n
    self
  end

  # Executors
  def count
    total_records = REDIS.zcard @model.meta_key(:id)

    if stop > @offset and stop < total_records
      return @limit
    else
      total_records - @offset
    end
  end

  def all
    ids.map {|id| @model.find id}
  end
  delegate :first, :last, :to => :all

private
  def ids
    REDIS.zrange @model.meta_key(:id), @offset, stop
  end

  def stop
    @limit ? @offset + @limit -1 : -1
  end

end
