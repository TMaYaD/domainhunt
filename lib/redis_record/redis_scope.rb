class RedisScope
  def initialize(model, *args)
    @model = model
    @offset = 0
    @filters = []
    @sort = :id
    @min = '-inf'
    @max = '+inf'
  end

  # Modifiers
  # always returns self

  def filter(name, value=true)
    if @model.defined_filters.include? name
      @filters.push @model.filter_key(name, value)
    else
      raise NameError, ":#{name} isn't in the defined filters"
    end

    self
  end

  def sort(attr)
    @sort = attr
    self
  end

  def min(value)
    @min = value
    self
  end

  def max(value)
    @max = value
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
    apply_filters
    total_records = REDIS.zcard temp_key

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
  delegate :first, :last, :each, :map, to: :all

private
  def ids
    apply_filters
    REDIS.zrangebyscore temp_key, @min, @max, limit: [@offset, @limit || -1]
  end

  def apply_filters
    key_sets = [@model.meta_key(@sort)] + @filters
    weights = [1] + [0] * @filters.count
    REDIS.zinterstore temp_key, key_sets, weights: weights
  end

  def temp_key
    @temp_key ||= @model.meta_key("Temp:Filtered")
  end
end
