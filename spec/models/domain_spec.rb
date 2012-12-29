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
      Domain.limit(2).all.map(&:id).should eq %w[0.com 1.com]
    end

    it "should return only records starting from 'offset'" do
      Domain.offset(3).all.map(&:id).should eq %w[3.com 4.com]
    end

    it "should return only 'limit' records starting from 'offset'" do
      Domain.offset(2).limit(2).all.map(&:id).should eq %w[2.com 3.com]

      # in any order
      Domain.limit(2).offset(2).all.map(&:id).should eq %w[2.com 3.com]
    end

    it "should not return more records than existing" do
      Domain.offset(3).limit(3).all.map(&:id).should eq %w[3.com 4.com]
    end

    it "should not display hidden records" do
      Domain.first.hide

      Domain.filter(:hidden, false).count.should eq 4
      Domain.filter(:hidden, false).all.map(&:id).should eq %w[1.com 2.com 3.com 4.com]
    end

    context 'with sorting' do
      before(:each) do
        (1..4).each {|i| Domain.create id: ('a' * i), status: 'Pre-release'}
      end

      it "should sort by given attribute" do
        Domain.sort(:length).map(&:id).should eq %w[a aa aaa aaaa 0.com 1.com 2.com 3.com 4.com]
      end

      it "should filter for min and max on the sort" do
        Domain.sort(:length).min(5).map(&:id).should eq %w[0.com 1.com 2.com 3.com 4.com]
        Domain.sort(:length).max(4).map(&:id).should eq %w[a aa aaa aaaa]
        Domain.sort(:length).min(2).max(4).map(&:id).should eq %w[aa aaa aaaa]
      end
    end

    context "with filters" do
      before(:each) do
        ('a'..'b').each { |i| Domain.create id: "#{i}.com", status: 'Pre-release' }
        ('5'..'6').each { |i| Domain.create id: "#{i}-.net", status: 'Pre-release' }
        ('a'..'b').each { |i| Domain.create id: "#{i}.org", status: 'Pre-release' }
      end

      it "shouldn't allow undefined filters" do
        expect{Domain.filter(:blah)}.to raise_error NameError
      end

      it "should return only records with the given filter applied" do
        Domain.filter(:numbers).all.map(&:id).should eq %w[0.com 1.com 2.com 3.com 4.com 5-.net 6-.net]
      end

      it "should return only records matching all the filters" do
        Domain.filter(:numbers).filter(:hyphenated).all.map(&:id).should eq %w[5-.net 6-.net]
      end

      it "should list out all the available values for a given filter" do
        Domain.values_for_filter(:tld).should eq %w[net org com]
      end

      it "should return records with the filter matching a custom value" do
        Domain.filter(:tld, 'net').map(&:id).should eq %w[5-.net 6-.net]
      end

      it "should return records with the filter matching any of the custom values" do
        Domain.filter(:tld, ['net', 'org']).map(&:id).should eq %w[5-.net 6-.net a.org b.org]
      end

      it "should sort and select records even when filters are applied" do
        (1..4).each {|i| Domain.create id: ('a' * i), status: 'Pre-release'}
        Domain.filter(:numbers, false).sort(:length).min(2).max(4).map(&:id).should eq %w[aa aaa aaaa]
      end

    end
  end
end
