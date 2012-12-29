class Comment < RedisRecord
  attr_accessible :id, :body
  string :id # domain name
  string :body

  validates :id, :presence => true
  validates :body, :presence => true

end
