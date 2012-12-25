require 'spec_helper'

describe Domain do
  it { should validate_presence_of :id }

  it { should validate_presence_of :status }
  it { should ensure_inclusion_of(:status).in_array Domain::STATUS_LIST }

  it "should import pre release domains" do
    file = fixture 'PreRelease.txt'
    expect {
      Domain.import 'Pre-release', file
    }.to change{Domain.count}.by(10)
    Domain.last.min_bid.should eq 69
  end

  it "should import standard auctions" do
    file = fixture 'StandardAuctions.csv'
    expect {
      Domain.import 'Auction', file
    }.to change{Domain.count}.by(15)
  end

  it "should import domains pending delete" do
    file = fixture '12-22-2012.txt'
    expect {
      Domain.import 'Pending-delete', file
    }.to change{Domain.count}.by(5)
  end

  context "as redis record" do
    before(:each) do
      (0..4).each { |i| Domain.create id: "#{i}.com", status: 'Pre-release' }
    end

    it "should return all the records" do
      Domain.count.should eq 5
      Domain.all.map(&:id).should eq %w[0.com 1.com 2.com 3.com 4.com]
    end

    it "should return only 'limit' number of records" do
      Domain.limit(2).count.should eq 2
      Domain.limit(2).all.map(&:id).should eq %w[0.com 1.com]
    end

    it "should return only records starting from 'offset'" do
      Domain.offset(3).count.should eq 2
      Domain.offset(3).all.map(&:id).should eq %w[3.com 4.com]
    end

    it "should return only 'limit' records starting from 'offset'" do
      Domain.offset(2).limit(2).count.should eq 2
      Domain.offset(2).limit(2).all.map(&:id).should eq %w[2.com 3.com]

      # in any order
      Domain.limit(2).offset(2).count.should eq 2
      Domain.limit(2).offset(2).all.map(&:id).should eq %w[2.com 3.com]
    end

    it "should not return more records than existing" do
      Domain.offset(3).limit(3).count.should eq 2
      Domain.offset(3).limit(3).all.map(&:id).should eq %w[3.com 4.com]
    end

    context "with filters" do
      before(:each) do
        ('a'..'e').each { |i| Domain.create id: "#{i}.com", status: 'Pre-release' }
        ('5'..'9').each { |i| Domain.create id: "#{i}.net", status: 'Pre-release' }
      end

      it "shouldn't allow undefined filters" do
        expect{Domain.filter(:blah)}.to raise_error NameError
      end

      it "should return only records with the given filter applied" do
        Domain.filter(:numbers).count.should eq 10
        Domain.filter(:numbers).all.map(&:id).should eq %w[0.com 1.com 2.com 3.com 4.com 5.net 6.net 7.net 8.net 9.net]
      end

    end
  end
end
