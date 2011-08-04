#= require map/google/common

namespace "sellstome.map.custom", (() ->
  #Import section
  googlemaps = google.maps
  LatLng = googlemaps.LatLng
  ZoomControlStyle = googlemaps.ZoomControlStyle
  Map = googlemaps.Map
  StyledMapType = googlemaps.StyledMapType
  MapTypeId = googlemaps.MapTypeId
  Customized = sellstome.googlemap.MapTypeId.Customized

  #Public members
  return {
    initializeGoogleMap: () ->
          latlngMap = new LatLng(36.146747, -76.997681);
          myOptions =
              zoom: 8
              center: latlngMap
              mapTypeControlOptions:
                mapTypeIds: [MapTypeId.ROADMAP, Customized]
              zoomControlOptions:
                style: ZoomControlStyle.SMALL
          map = new Map document.getElementById("map_canvas") , myOptions
          mapStyle = [{ featureType: "road", elementType: "geometry", stylers: [{ hue: "#ff3333" },{ saturation:100 }] },
                      { featureType: "landscape", elementType: "geometry", stylers: [{ lightness: -20 }] },
                      { featureType: "administrative.locality", elementType: "labels", stylers: [{ visibility: "off" }]},
                      { featureType: "road", elementType: "labels", stylers: [{ visibility: "off" }]}]

          styledMapOptions = {
              name: "Trash"
          }

          customizedMapType = new StyledMapType mapStyle, styledMapOptions
          map.mapTypes.set Customized, customizedMapType
          map.setMapTypeId Customized
        }
)()

jQuery(document).ready sellstome.map.custom.initializeGoogleMap