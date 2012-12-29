class RedisScope
  DEFAULT_OPTIONS = {
      offset:   0,
      filters:  [],
      sort:     :id,
      min:      '-inf',
      max:      '+inf'
    }

  def initialize(model, opts = {})
    @model = model
    @options = DEFAULT_OPTIONS.merge opts
  end

  # Modifiers
  # always returns self

  def filter(name, value=true)
    raise NameError, ":#{name} isn't in the defined filters" unless @model.defined_filters.include? name
    new_filters = @options[:filters] + [[name, value]]

    chain_scope filters: new_filters
  end

  def sort(attr)
    chain_scope sort: attr
  end

  def min(value)
    chain_scope min: value
  end

  def max(value)
    chain_scope max: value
  end

  def limit(n)
    chain_scope limit: n
  end

  def offset(n)
    chain_scope offset: n
  end

  # Executors
  def count
    apply_filters
    total_records = REDIS.zcard temp_key

    remaining_records = total_records - @options[:offset]

    if @options[:limit] and @options[:limit] < remaining_records
      @options[:limit]
    else
      remaining_records
    end
  end

  def all
    ids.map {|id| @model.find id}
  end
  delegate :each, :map, to: :all
  delegate :as_json, to: :all

  def first
    limit(1).all[0]
  end

  def last
    offset(@options[:offset] + count - 1).limit(1).all[0]
  end

private
  def chain_scope(opts = {})
    self.class.new @model, @options.merge(opts)
  end

  def ids
    apply_filters
    REDIS.zrangebyscore temp_key, @options[:min], @options[:max], limit: [@options[:offset], @options[:limit] || -1]
  end

  def apply_filters
    filter_keys = @options[:filters].map do |name, value|
      if value.is_a? Array
        values = value
        union_key = @model.filter_key "_Union:#{name}", values.join('_')
        value_keys = values.map {|value| @model.filter_key name, value}
        REDIS.zunionstore union_key, value_keys
        union_key
      else
        @model.filter_key name, value
      end
    end
    key_sets = [@model.meta_key(@options[:sort])] + filter_keys
    weights = [1] + [0] * @options[:filters].count
    REDIS.zinterstore temp_key, key_sets, weights: weights
  end

  def temp_key
    @temp_key ||= @model.meta_key("_Temp:Filtered")
  end

end
