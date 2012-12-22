require 'csv'

class Domain < RedisRecord
  STATUS_LIST = %w(Pre-release Pending-delete Auction)

  attr_accessible :id, :min_bid, :release_date, :status, :min_bid_with_unit, :end_date

  string   :id # name
  decimal  :min_bid
  date     :release_date
  string   :status
  datetime :end_date

  validates :id,  :presence => true
  validates :status,  :presence => true,
                      :inclusion => { :in => STATUS_LIST }

  def self.import(status, file)
    parse_records(file.path, status) do |row|
      domain = find_or_initialize_by_id row['id']
      domain.update_attributes row.to_hash.merge(status: status)
    end
  end

  def min_bid_with_unit=(value)
    self.min_bid = value && value[1..-1]
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
