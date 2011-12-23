#require vendor/underscore
#require mvc
#require ui/base
#require ui/generators

namespace "sm.ui", (exports) ->
  
  {ui,mvc} = sm
  {UIView} = ui
  {DomlessView} = mvc
  {generateCircle,generateRect,generatePriceBubble} = sm.generators
  
  class UIMapMarker extends DomlessView
    Size = Point = Map = LatLng = MarkerImage = Marker = null
    cache: {}
    initialize: (options) ->
      super(options)
      @gmap = google.maps
      {Size, Point, Map, LatLng, MarkerImage, Marker} = @gmap
      {@event} = @gmap
      @markerData = @_generatePriceMarkers(@model.get('price').toString())
      @location = @model.get('location')
    render: (map) ->
      delete @marker if @marker?
      @marker = new Marker
        position: new LatLng(@location.latitude, @location.longitude)
        map: map
        icon: @markerData[0]
        shape: @markerData['shape']
      @event.addListener @marker, 'mouseover', _.bind(@on_mouseover, this)
      @event.addListener @marker, 'mouseout',  _.bind(@on_mouseout, this)
    remove: ->
      @marker.setMap(null)
    on_click:     (e) -> @trigger('click', this) 
    on_mouseover: (e) -> 
      @marker.setZIndex(100)
      @marker.setIcon(@markerData[1])
      @trigger('mouseover', this)
    on_mouseout:  (e) -> 
      @marker.setZIndex(1)
      @marker.setIcon(@markerData[0])
      @trigger('mouseout', this)
    _generatePriceMarkers: (price) ->
      unless @cache[price]?
        @cache[price] = {}
        bubble = generatePriceBubble "$#{price}",
          font: '11px Geneva'
          color: '#444'
          fillStyle: 'rgba(0,200,0,0.6)'
          strokeStyle: 'rgba(0,120,0,0.6)'
        @cache[price][0] = new MarkerImage(
          bubble.image,
          new Size(bubble.width,bubble.height),
          new Point(0,0),
          new Point(bubble.anchorX,bubble.anchorY))
        @cache[price]['shape'] = bubble.shape

        bubble = generatePriceBubble "$#{price}",
          font: '11px Geneva'
          color: '#444'
          fillStyle: 'rgba(245,50,50,0.9)'
          strokeStyle: 'rgba(120,20,20,0.9)'
        @cache[price][1] = new MarkerImage(
          bubble.image,
          new Size(bubble.width,bubble.height),
          new Point(0,0),
          new Point(bubble.anchorX,bubble.anchorY))
      return @cache[price]
  
  class UIMap extends UIView
    Size = Point = Map = LatLng = MarkerImage = Marker = null
    initialize: (options) ->
      super(options)
      @views = {}
      unless google?
      then $app.bind('gmap-load', @_initializeCompletion, this)
      else @_initializeCompletion(google.maps)
    _initializeCompletion: (gmap) ->
      @gmap = gmap
      {Size, Point, Map, LatLng, MarkerImage, Marker} = @gmap
      @renderMap()
    
    renderMap: ->
      mapCenterPosition = new LatLng(53.902257,27.561640)
      options =
        zoom: 12
        center: mapCenterPosition
        mapTypeId: @gmap.MapTypeId.ROADMAP
        disableDefaultUI: true
      @map = new Map($(@el).get(0), options)
        
    renderMarkers: (collection) ->
      return if collection.length is 0
      @clearMarkers()
      collection.each (model) =>
        view = new UIMapMarker(model: model)
        view.render(@map)
        @views[view.cid] = view
      location = collection.models[0].get('location')
      @map.setCenter(new LatLng(location.latitude,location.longitude))
      
    clearMarkers: ->
      for cid, view of @views
        view.remove()
        delete view
      @views = {}
    refresh: ->
      return unless @gmap
      _.defer => @gmap.event.trigger(@map, 'resize')

  exports extends {UIMap}