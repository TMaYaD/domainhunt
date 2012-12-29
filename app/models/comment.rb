class Comment < RedisRecord
  attr_accessible :id, :body, :domain_id
  string :id # domain name
  string :body

  validates :id, :presence => true
  validates :body, :presence => true

  def domain_id
    id
  end

  def domain_id=(name)
    id = name
  end
end
