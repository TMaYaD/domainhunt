require 'csv'

class Domain < ActiveRecord::Base
  STATUS_LIST = %w(Pre-release Pending-delete Auction)

  attr_accessible :min_bid, :name, :release_date, :status, :min_bid_with_unit, :end_date

  validates :name,  :presence => true,
                    :uniqueness => true
  validates :status,  :presence => true,
                      :inclusion => { :in => STATUS_LIST }

  def self.import(status, file)
    parse_records(file.path, status) do |row|
      domain = self.where(name: row['name']).first_or_initialize
      domain.attributes = row.to_hash.merge(status: status)
      domain.save
    end
  end

  def min_bid_with_unit=(value)
    self.min_bid = value && value[1..-1]
  end

private
  def self.parse_records(path, status, &block)
    case status
    when 'Pre-release'
      CSV.foreach(path, headers: %w[name release_date min_bid_with_unit], &block)
    when 'Auction'
      CSV.foreach(path, headers: %w[name end_date], &block)
      self.find_by_name('DomainName').destroy
    when 'Pending-delete'
      CSV.foreach(path, headers: %w[name], &block)
    end
  end
end
