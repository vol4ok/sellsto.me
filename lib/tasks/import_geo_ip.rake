require 'csv'

task :import_geo_ip_data => :environment do
  locations = Hash.new
  index = 0
  CSV.foreach("#{Rails.root}/data/GeoLiteCity-Location.csv",{ :encoding => "ASCII-8BIT:UTF-8" }) do |row|
    if index > 1 then
      locations[row[0].to_i] = row
    elsif index < 1
      print row[0].encoding.name
    end
    index += 1
  end

  #parse main geodata file
  index = 0
  CSV.foreach("#{Rails.root}/data/GeoLiteCity-Blocks.csv",{ :encoding => "ASCII-8BIT:UTF-8" }) do |row|
    if index > 1 then
      location = locations[row[2].to_i]
      raise RuntimeError, "couldn't find location" if location.nil?
      #import record to a database
      startIp = row[0].to_i
      endIp = row[1].to_i
      IpToLocation.create( start_ip: startIp , end_ip: endIp ) do |ipToLocation|
        ipToLocation.country =     location[1]
        ipToLocation.region =      location[2]
        ipToLocation.city =        location[3]
        ipToLocation.postal_code = location[4]
        ipToLocation.latitude =    location[5].to_f if not location[5].nil?
        ipToLocation.longitude =   location[6].to_f if not location[6].nil?
        ipToLocation.metro_code =  location[7].to_i if not location[7].nil?
        ipToLocation.area_code =   location[8].to_i if not location[8].nil?
      end
    end
    index += 1
  end

end