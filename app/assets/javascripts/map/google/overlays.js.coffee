# This file would be used for implementing sellstome Google Map overlays
# We currently using v3 Google map javascript API
# @author Zhugrov Aliaksandr

namespace "sellstome.googlemap.overlays", (() ->

  InfoWindow = ( options ) ->
    this._content = options.content
    # dom element that holds window dom representation
    this._container = null
    # @type: google.maps.LatLng
    this._position = null
    return

  _proto = InfoWindow.prototype = new google.maps.OverlayView()

  #redefine functions that are called by Google Map API

  _proto.onAdd = () ->
    container = document.createElement "div"
    jQuery(container).html this._content
    this._container = container
    panes = this.getPanes()
    panes.floatPane.appendChild container
    return
  _proto.draw = () ->
    overlayProjection = this.getProjection()
    offsetPoint = overlayProjection.fromLatLngToDivPixel this._position
    container = this._container
    jQuery(container).css
      position: "absolute"
      left: offsetPoint.x
      top: offsetPoint.y
      background: "white"
      height: "60px"
      width: "130px"
    return
  _proto.onRemove = () ->
    jQuery(_container).remove()
    this._container = null
    return

  #define other interface functions
  # @param anchor - currently the only supported anchor is google.maps.Marker
  _proto.open = (map, anchor) ->
    this._position = anchor.getPosition()
    this.setMap map
    return
  return {
    InfoWindow: InfoWindow
  }
)()


namespace "sellstome.googlemap.overlays", (() ->

  Canvas = ( options ) ->
    # dom element that holds window dom representation
    this._container = null
    this._options = options
    # set map and invokes initialization of element
    this.setMap options.map
    return

  _proto = Canvas.prototype = new google.maps.OverlayView()

  #redefine functions that are called by Google Map API

  _proto.onAdd = () ->
    container = document.createElement "canvas"
    this._container = container
    panes = this.getPanes()
    panes.overlayLayer.appendChild container
    ctx = container.getContext("2d")
    ctx.fillStyle = "rgb(200,0,0)"
    ctx.fillRect 10, 10, 55, 50
    return
  _proto.draw = () ->
    overlayProjection = this.getProjection()
    container = this._container
    offsetPoint = overlayProjection.fromLatLngToDivPixel this._options.position
    jQuery(container).css
      position: "absolute"
      left: offsetPoint.x
      top:  offsetPoint.y
      height: "300px"
      width: "300px"
    return
  _proto.onRemove = () ->
    jQuery(_container).remove()
    this._container = null
    return

  return {
    Canvas: Canvas
  }
)()
