# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :domain do
    name "MyString"
    min_bid "9.99"
    release_date "2012-12-22"
    status "MyString"
  end
end
