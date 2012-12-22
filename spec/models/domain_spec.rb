require 'spec_helper'

describe Domain do
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of :name }

  it { should validate_presence_of :status }
  it { should ensure_inclusion_of(:status).in_array Domain::STATUS_LIST }

  it "should import pre release domains" do
    file = File.new Rails.root.join('spec', 'fixtures', 'PreRelease.txt'), 'r'
    expect {
      Domain.import 'Pre-release', file
    }.to change{Domain.count}.by(10)
    Domain.last.min_bid.should eq 69
  end

  it "should import standard auctions" do
    file = File.new Rails.root.join('spec', 'fixtures', 'StandardAuctions.csv'), 'r'
    expect {
      Domain.import 'Auction', file
    }.to change{Domain.count}.by(15)
  end

  it "should import domains pending delete" do
    file = File.new Rails.root.join('spec', 'fixtures', '12-22-2012.txt'), 'r'
    expect {
      Domain.import 'Pending-delete', file
    }.to change{Domain.count}.by(5)
  end
end
