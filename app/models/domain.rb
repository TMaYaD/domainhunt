require 'csv'

class Domain < RedisRecord
  STATUS_LIST = %w(Pre-release Pending-delete Auction)

  attr_accessible :id, :min_bid, :min_bid_with_unit, :release_date, :status, :end_date
  attr_accessible :hidden, :liked

  string    :id # name
  decimal   :min_bid
  date      :release_date
  string    :status
  datetime  :end_date
  boolean   :hidden, :default => false
  boolean   :liked, :default => false

  validates :id,  :presence => true
  validates :status,  :presence => true,
                      :inclusion => { :in => STATUS_LIST }

  create_filter :numbers do |domain|
    !!domain.id.match(/[0-9]/)
  end
  create_filter :hyphenated do |domain|
    !!domain.id.match(/-/)
  end
  create_filter :tld do |domain|
    domain.id.split('.').last
  end

  create_filter :hidden
  create_filter :liked

  sortable :length do |domain|
    domain.id.length
  end

  def self.import(status, path)
    parse_records(path, status) do |row|
      domain = find_or_initialize_by_id row['id']
      domain.update_attributes row.to_hash.merge(status: status)
    end
  end

  def min_bid_with_unit=(value)
    self.min_bid = value && value[1..-1]
  end

  def hide
    update_attributes hidden: true
  end

  def toggle_like(state = nil)
    state ||= !liked
    update_attributes liked: state
  end

  def comment
    Comment.find_or_initialize_by_id(id)
  end

private
  def self.parse_records(path, status, &block)
    case status
    when 'Pre-release'
      CSV.foreach(path, headers: %w[id release_date min_bid_with_unit], &block)
    when 'Auction'
      ActiveAttr::Typecasting::DateTimeTypecaster.with_date_format do
        CSV.foreach(path, headers: %w[id end_date], &block)
      end
      self.find('DomainName').destroy
    when 'Pending-delete'
      CSV.foreach(path, headers: %w[id], &block)
    end
  end
end
