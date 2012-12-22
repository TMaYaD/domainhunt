class Domain < ActiveRecord::Base
  STATUS_LIST = %w(Pre-release Pending-delete Auction)

  attr_accessible :min_bid, :name, :release_date, :status

  validates :name,  :presence => true,
                    :uniqueness => true
  validates :status,  :presence => true,
                      :inclusion => { :in => STATUS_LIST }

  def self.import(status, file)
    # TODO: Import domains from the file, parse the CSV and save records
  end
end
