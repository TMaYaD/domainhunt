require 'csv'

FLAGS_FILE = Rails.root.join 'db', 'flags.yml'
COMMENTS_FILE = Rails.root.join('db', 'comments.csv')

desc "Import files from seed folder into redis"
task :import => :environment do
  Domain::STATUS_LIST.each do |status|
    Dir[Rails.root.join 'db', 'seeds', status, '*.*'].each do |f|
      Domain.import status, f
    end
  end

  flags = YAML.load_file(FLAGS_FILE)
  flags[:hidden_ids].each do |id|
    Domain.find(id).hide
  end

  flags[:liked_ids].each do |id|
    Domain.find(id).toggle_like true
  end

  CSV.foreach(COMMENTS_FILE, headers: %w[id body]) do |row|
    Comment.create row.to_hash
  end
end

desc "Export likes, hides and comments to csv files"
task :export => :environment do
  CSV.open(COMMENTS_FILE, 'w') do |csv|
    Comment.each do |comment|
      csv << comment.attributes.values
    end
  end

  File.open(FLAGS_FILE, 'w') do |f|
    f << {
      hidden_ids: REDIS.smembers(Domain.filter_key(:hidden, true)),
      liked_ids: REDIS.smembers(Domain.filter_key(:liked, true))
    }.to_yaml
  end
end
