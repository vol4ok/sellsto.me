require 'csv'

task :import_geo_ip_data => :environment do

  system "mongoimport --host localhost --db sells2me_api_dev --collection ip_locations --fields loc_id,country,region,city,postal_code,latitude,longitude,metro_code,area_code --type csv --file #{Rails.root}/data/GeoLiteCity-Location.csv --upsert"

  system "mongoimport --host localhost --db sells2me_api_dev --collection ip_to_locations --fields start_ip,end_ip,loc_id --type csv --file #{Rails.root}/data/GeoLiteCity-Blocks.csv --upsert"

end