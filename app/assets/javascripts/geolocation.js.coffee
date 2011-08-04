#= require map/geolocation/common

namespace "sellstome.map.geolocation", (() ->
  #Import section
  googlemaps = google.maps
  LatLng = googlemaps.LatLng
  ZoomControlStyle = googlemaps.ZoomControlStyle
  Map = googlemaps.Map
  MapTypeId = googlemaps.MapTypeId
  Circle = googlemaps.Circle
  GeolocationRequest = sellstome.geolocation.GeolocationRequest

  #Private members
  googleMap = null
  marker = null
  getPositionCallback = (position) ->
    if googleMap?
      latlngMap = new LatLng position.coords.latitude, position.coords.longitude
      googleMap.setCenter latlngMap
      #draw a little circle to indicate a current user position
      if not marker?
        circleOptions =
              strokeColor: "#FF0000"
              strokeOpacity: 0.8
              strokeWeight: 2
              fillColor: "#FF0000"
              fillOpacity: 0.35
              map: googleMap
              center: latlngMap
              radius: 1700
        marker = new Circle circleOptions
      else
        marker.setCenter latlngMap

  #Public members
  return {
    initializeGoogleMap: () ->
          latlngMap = new LatLng -34.397, 150.644
          mapOptions =
              zoom: 8
              center: latlngMap
              mapTypeControlOptions:
                mapTypeIds: [MapTypeId.ROADMAP]
              mapTypeId: MapTypeId.ROADMAP
              zoomControlOptions:
                style: ZoomControlStyle.SMALL
          googleMap = new Map document.getElementById("map_canvas") , mapOptions
          request = new GeolocationRequest()
          jQuery("[id=findPosition]").click () ->
            request.getCurrentPosition getPositionCallback
          return
  }
)()

jQuery(document).ready sellstome.map.geolocation.initializeGoogleMap
