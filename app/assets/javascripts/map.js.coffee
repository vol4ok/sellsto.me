#= require lang
#= require map/controls
#= require map/overlays
#= require jquery

namespace "sellstome.map", (exports) ->
  # import section
  googlemaps = google.maps
  LatLng = googlemaps.LatLng
  Marker = googlemaps.Marker
  MapTypeId = googlemaps.MapTypeId
  ZoomControlStyle = googlemaps.ZoomControlStyle
  Map = googlemaps.Map
  Circle = googlemaps.Circle
  ControlPosition = googlemaps.ControlPosition
  sellstomemap = sellstome.map
  RadiusSelector = sellstomemap.RadiusSelector
  Canvas = sellstomemap.Canvas


  #Private members
  markers = new Array()

  clearMap = () ->
          for marker in markers
              marker.setMap null
          markers.splice 0, markers.length

  #Public members
  initializeGoogleMap = () ->
          latlngMap = new LatLng -34.397, 150.644
          myOptions =
              zoom: 8
              center: latlngMap
              mapTypeId: MapTypeId.TERRAIN
              zoomControlOptions:
                style: ZoomControlStyle.SMALL
          map = new Map document.getElementById("map_canvas") , myOptions
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
          circle = new Circle(circleOptions)

          canvasLayer = new Canvas({map: map, position: latlngMap})

          # here we are adding our custom control
          radiusSelectorControl = new RadiusSelector circle
          map.controls[ControlPosition.RIGHT_CENTER].push radiusSelectorControl

  loadMoreData = () ->
      clearMap()
      jQuery.ajax
          url: "/map/search.json"
          success: (results) ->
              i = 0
              for result in results
                  if i > 20
                      break
                  marker = new Marker
                      position: new LatLng(result.latitude, result.longitude)
                      map: window.googleMap
                      title: "Hello World!"
                  markers.push marker
                  i++

  exports.initializeGoogleMap = initializeGoogleMap
  exports.loadMoreData = loadMoreData

jQuery(document).ready () ->
    #Yes. I hate typing namespaces everywhere. I need to implement aliasing runtime first and them
    #we should implement a more static approach
    sellstome.map.initializeGoogleMap()
    jQuery("[id=load_new]").click sellstome.map.loadMoreData