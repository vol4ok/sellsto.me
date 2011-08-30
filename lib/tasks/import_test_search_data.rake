require 'mongo'

task :import_test_search_data do
  db = Mongo::Connection.new.db("sells2me_api_dev")
  db.drop_collection("test_search_data")
  search_data = db.collection("test_search_data")
  doc = {
    "body" => "Hi this is first imported data peace",
    "price" => 300,
    "location" => {
        "latitude"  => 56.3,
        "longitude" => 35
    },
    "attachments" => "http://local.sellstome.com/image.jpg",
    "created_at" => Time.current,
    "updated_at" => Time.current
  }
  search_data.insert(doc)
end