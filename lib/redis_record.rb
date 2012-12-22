require 'active_attr'

class RedisRecord

	Dir[File.expand_path("../redis_record/**/*.rb", __FILE__)].each {|f| require f}

  include ActiveAttr::Model
  include DataTypes
  include Base


  class_attribute :sorted_indices
  self.sorted_indices = []

end
