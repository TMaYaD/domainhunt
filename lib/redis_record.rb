require 'active_attr'
require 'active_support'

class RedisRecord

	Dir[File.expand_path("../redis_record/**/*.rb", __FILE__)].each {|f| require f}

  include ActiveAttr::Model
  include DataTypes
  include Base


  class_attribute :defined_sorts, :defined_filters
  self.defined_sorts = {id: nil}
  self.defined_filters = {}

  ActiveSupport.run_load_hooks :redis_record, self
end
