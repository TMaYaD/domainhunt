require 'csv'

desc "Import files from seed folder into redis"
task :import => :environment do
  Domain::STATUS_LIST.each do |status|
    Dir[Rails.root.join 'db', 'seeds', status, '*.*'].each do |f|
      Domain.import status, f
    end
  end
end

desc "Export likes, hides and comments to csv files"
task :export => :environment do
  CSV.open(Rails.root.join('db', 'comments.csv'), 'w') do |csv|
    Comment.each do |comment|
      csv << comment.attributes.values
    end
  end

  File.open(Rails.root.join('db', 'flags.yml'), 'w') do |f|
    f << {
      hidden_ids: REDIS.smembers(Domain.filter_key(:hidden, true)),
      liked_ids: REDIS.smembers(Domain.filter_key(:liked, true))
    }.to_yaml
  end
end
