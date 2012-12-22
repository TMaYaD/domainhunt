require 'spec_helper'

describe Domain do
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of :name }

  it { should validate_presence_of :status }
  it { should ensure_inclusion_of(:status).in_array Domain::STATUS_LIST }

  it "should import pre release domains" do
    Domain.import('Pre-release', 'fixtures/pre-realease-domains-list.txt')
    # TODO: write some real tests
  end
end
