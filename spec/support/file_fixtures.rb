module FileFixtures
  FIXTURE_PATH = "#{::Rails.root}/spec/fixtures"
  def fixture(file)
    File.expand_path(file, FIXTURE_PATH)
  end
end

RSpec.configure do |c|
  c.include FileFixtures
end
