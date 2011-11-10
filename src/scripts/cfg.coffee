namespace "sm.cfg", (exports) ->
  
  GMAP_API_KEY = 'ABQIAAAAYUB6q4UJksDvp1TvGGHG_BQNYqpsCpiTg7NWK5aiP4T3BBIq-RRZOwE9ta7QktesY-NgAnSC2S6aiw'
  
  exports extends
    GMAP_JS_URL: "http://maps.google.com/maps/api/js?sensor=false&key=#{GMAP_API_KEY}"