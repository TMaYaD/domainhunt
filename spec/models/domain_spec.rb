require 'spec_helper'

describe Domain do
  it { should validate_presence_of :id }

  it { should validate_presence_of :status }
  it { should ensure_inclusion_of(:status).in_array Domain::STATUS_LIST }

  it "should import pre release domains" do
    file = fixture 'PreRelease.txt'
    expect {
      Domain.import 'Pre-release', file
    }.to change{Domain.all.count}.by(10)
    Domain.last.min_bid.should eq 69
  end

  it "should import standard auctions" do
    file = fixture 'StandardAuctions.csv'
    expect {
      Domain.import 'Auction', file
    }.to change{Domain.all.count}.by(15)
  end

  it "should import domains pending delete" do
    file = fixture '12-22-2012.txt'
    expect {
      Domain.import 'Pending-delete', file
    }.to change{Domain.all.count}.by(5)
  end
end
