require 'mongo'

task :import_test_search_data do
  #contain rectangular bounds for the Minsk City
  TOP_LATITUDE = 53.97183955821782
  BOTTOM_LATITUDE = 53.83470154834172
  LEFT_LONGITUDE = 27.4163818359375
  RIGHT_LONGITUDE = 27.684860229492188

  db = Mongo::Connection.new.db("sells2me_api_dev")
  db.drop_collection("test_search_datas")
  search_data = db.collection("test_search_datas")
  for i in 1..10000
    #User add sample data
    doc = {
      "body" => "user add with uniform distribution no. #{i}",
      "price" => rand(1000),
      "location" => {
          "latitude"  => BOTTOM_LATITUDE + rand() * (TOP_LATITUDE - BOTTOM_LATITUDE),
          "longitude" => LEFT_LONGITUDE + rand() * (RIGHT_LONGITUDE - LEFT_LONGITUDE)
      },
      #todo zhugrov a - replace with more correct data
      "attachments" => "http://sellstome.com:3000/image.jpg",
      "created_at" => Time.current,
      "updated_at" => Time.current
    }
    search_data.insert(doc)
  end
end