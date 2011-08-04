#= require map/google/controls
#= require map/google/overlays

namespace "sellstome.map", (() ->
  #Private members
  markers = new Array()

  clearMap = () ->
          for marker in markers
              marker.setMap null
          markers.splice 0, markers.length

  #Public members
  return {
      initializeGoogleMap: () ->
          latlngMap = new google.maps.LatLng -34.397, 150.644
          myOptions =
              zoom: 8
              center: latlngMap
              mapTypeId: google.maps.MapTypeId.TERRAIN
              zoomControlOptions:
                style: google.maps.ZoomControlStyle.SMALL
          map = new google.maps.Map document.getElementById("map_canvas") , myOptions
          window.googleMap = map
          circleOptions =
            strokeColor: "#FF0000"
            strokeOpacity: 0.8
            strokeWeight: 2
            fillColor: "#FF0000"
            fillOpacity: 0.35
            map: map
            center: latlngMap
            radius: 1700
          circle = new google.maps.Circle circleOptions

          # here we are adding our custom control
          radiusSelectorControl = new sellstome.googlemap.controls.RadiusSelector circle
          map.controls[google.maps.ControlPosition.RIGHT_CENTER].push radiusSelectorControl

      loadMoreData: () ->
          clearMap()
          jQuery.ajax
              url: "/map/search.json"
              success: (results) ->
                  i = 0
                  for result in results
                      if i > 20
                          break
                      marker = new google.maps.Marker
                          position: new google.maps.LatLng(result.latitude, result.longitude)
                          map: window.googleMap
                          title: "Hello World!"
                      markers.push marker
                      i++
  }
)()

jQuery(document).ready () ->
    #Yes. I hate typing namespaces everywhere. I need to implement aliasing runtime first and them
    #we should implement a more static approach
    sellstome.map.initializeGoogleMap()
    jQuery("[id=load_new]").click sellstome.map.loadMoreData