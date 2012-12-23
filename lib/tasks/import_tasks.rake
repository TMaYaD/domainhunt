desc "Import files from seed folder into redis"
task :import => :environment do
  Domain::STATUS_LIST.each do |status|
    Dir[Rails.root.join 'db', 'seeds', status, '*.*'].each do |f|
      Domain.import status, f
    end
  end
end
