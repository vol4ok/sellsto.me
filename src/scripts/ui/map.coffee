#require vendor/underscore
#require mvc
#require ui/base
#require ui/generators
#require vendor/leaflet-latest/leaflet-src

namespace "sm.ui", (exports) ->
  
  {ui,mvc} = sm
  {UIView} = ui
  {DomlessView} = mvc
  {generateCircle,generateRect,generatePriceBubble} = sm.generators

  class UIMapMarker extends DomlessView

    cache: {}
    initialize: (options) ->
      super(options)
      @markerData = @_generatePriceMarkers(@model.get('price').toString())
      @location = @model.get('location')
    render: (map) ->
      delete @marker if @marker?
      return
    remove: ->
      return
    on_click:     (e) ->
      @trigger('click', this)
      return
    on_mouseover: (e) -> 
      @trigger('mouseover', this)
      return
    on_mouseout:  (e) -> 
      @trigger('mouseout', this)
      return
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
      mapQuestUrl = 'http://{s}.mqcdn.com/tiles/1.0.0/osm/{z}/{x}/{y}.jpg'
      subDomains = ['otile1','otile2','otile3','otile4']
      mapQuestAttribution = 'Data, imagery and map information provided by <a href="http://open.mapquest.co.uk" target="_blank">MapQuest</a>,
                                <a href="http://www.openstreetmap.org/" target="_blank">OpenStreetMap</a> and contributors.'
      mapLayer = new L.TileLayer(mapQuestUrl, {maxZoom: 18, attribution: mapQuestAttribution, subdomains: subDomains})
      @map = new L.Map($(@el).attr('id'))
      @map.setView(new L.LatLng(51.505, -0.09), 13).addLayer(mapLayer)

    renderMarkers: (collection) ->
      return if collection.length is 0
      @clearMarkers()
      collection.each (model) =>
        view = new UIMapMarker(model: model)
        view.render(@map)
        @views[view.cid] = view
      return this
      
    clearMarkers: ->
      for cid, view of @views
        view.remove()
        delete view
      @views = {}
      return this

    refresh: ->
      @map.invalidateSize()
      return this

    getBounds: ->
      return this

  exports extends {UIMap}