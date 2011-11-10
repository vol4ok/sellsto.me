#require underscore
#require ui/base

namespace "sm.ui", (exports) ->
  
  {ui} = sm
  {UIView} = ui
  
  class UIMap extends UIView
    
    initialize: (options) ->
      super(options)
      console.log 'initialize UIMap'
      $app.bind('gmap-load', @_initializeCompletion, this)
    _initializeCompletion: (gmap) ->
      @gmap = gmap
      @renderMap()
    
    renderMap: ->
      console.log 'renderMap'
      mapCenterPosition = new @gmap.LatLng(53.902257,27.561640)
      options =
        zoom: 12
        center: mapCenterPosition
        mapTypeId: @gmap.MapTypeId.ROADMAP
        disableDefaultUI: true
      @map = new @gmap.Map($(@el).get(0), options)
      
  exports extends {UIMap}