#require vendor/underscore
#require mvc
#require ui/base
#require ui/generators
#require vendor/leaflet-latest/leaflet-src

namespace "sm.ui", (exports) ->
  ## import section ##
  {ui,mvc}                                          = sm
  {UIView}                                          = ui
  {DomlessView}                                     = mvc
  {generatePriceBubble} = sm.generators
  {Map,TileLayer,LatLng,Marker}                     = L
  ####################

  markerIconCache                                   = {}

  class UIMapMarker extends DomlessView
    ### Marker delegate object ###
    marker: null

    initialize: (options) ->
      super(options)
      price    = @model.get('price')
      location = @model.get('location')
      @marker = new Marker(new LatLng(location.lat, location.lng),
        icon:       @_generatePriceMarkers(price)
      )
      @marker.on('click', @on_click, this)

    ### Renders marker on map ###
    render: (map) ->
      map.addLayer(@marker)
      return this

    ### Removes marker from map ###
    remove: (map) ->
      map.removeLayer(@marker)
      return this

    on_click:     (e) ->
      @trigger('click', this)
      return

    on_mouseover: (e) ->
      ## todo zhugrov a - currently does not supported by marker api
      @trigger('mouseover', this)
      return

    on_mouseout:  (e) ->
      ## todo zhugrov a - currently does not supported by marker api
      @trigger('mouseout', this)
      return

    _generatePriceMarkers: (price) ->
      unless markerIconCache[price]?

        markerIconCache[price] = {}

        bubble = generatePriceBubble "$#{price}",
            font:         '11px Geneva'
            color:        '#444'
            fillStyle:    'rgba(0,200,0,0.6)'
            strokeStyle:  'rgba(0,120,0,0.6)'

        PriceIcon = L.Icon.extend(
            iconUrl:      bubble.image
            iconSize:     new L.Point(bubble.width,   bubble.height)
            iconAnchor:   new L.Point(bubble.anchorX, bubble.anchorY)
            shadowUrl:    null ##disable shadow for a while
        )

        markerIconCache[price] = new PriceIcon()

      return markerIconCache[price]
  
  class UIMap extends UIView

    initialize: (options) ->
      super(options)
      @views = {}
      mapQuestUrl         = 'http://{s}.mqcdn.com/tiles/1.0.0/osm/{z}/{x}/{y}.jpg'
      subDomains          = ['otile1','otile2','otile3','otile4']
      mapQuestAttribution = 'Data, imagery and map information provided by <a href="http://open.mapquest.co.uk" target="_blank">MapQuest</a>,
                                <a href="http://www.openstreetmap.org/" target="_blank">OpenStreetMap</a> and contributors.'
      mapLayer = new TileLayer(mapQuestUrl, {maxZoom: 18, attribution: mapQuestAttribution, subdomains: subDomains})
      @map     = new Map($(@el).attr('id'))
      @map.setView(new LatLng(40.78, -73.87), 13).addLayer(mapLayer)

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
        view.remove(@map)
        delete view
      @views = {}
      return this

    refresh: ->
      @map.invalidateSize()
      return this

    ### Gets a bound rectangle of underlying map. ###
    getBounds: ->
      return @map.getBounds()

  exports extends {UIMap}