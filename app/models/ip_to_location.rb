class IpToLocation
  include Mongoid::Document

  field :start_ip, type: Integer
  field :end_ip, type: Integer
  field :country, type: String
  field :region, type: String
  field :city, type: String
  field :postal_code, type: String
  field :latitude, type: Float
  field :longitude, type: Float
  field :metro_code, type: Integer
  field :area_code, type: Integer

end