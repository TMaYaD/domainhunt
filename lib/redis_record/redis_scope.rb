class RedisScope
  def initialize(model, *args)
    @model = model
    @offset = 0
    @filters = [@model.meta_key(:id)]
  end

  # Modifiers
  # always returns self

  def filter(*filters)
    filters.each do|f|
      if @model.defined_filters.include? f
        @filters.push @model.meta_key("Filter:#{f}")
      else
        raise NameError, "#{f} isn't in the defined filters"
      end
    end
    self
  end

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
    total_records = REDIS.zcard zset_key

    remaining_records = total_records - @offset

    if @limit and @limit < remaining_records
      @limit
    else
      remaining_records
    end
  end

  def all
    ids.map {|id| @model.find id}
  end
  delegate :first, :last, :each, to: :all

private
  def ids
    REDIS.zrangebyscore zset_key, '-inf', '+inf', limit: [@offset, @limit || -1]
  end

  def zset_key
    key = @model.meta_key("Temp:Filtered")
    REDIS.zinterstore key,  @filters
    key
  end
end
