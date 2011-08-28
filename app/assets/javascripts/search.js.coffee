#= require lang
#= require map/controls
#= require map/overlays
#= require map/geolocation
#= require jquery
#= require backbone
#= require backbone_ext

namespace "sellstome.search", (exports) ->

	{LatLng, Marker, MapTypeId, ZoomControlStyle, 
		Map, Circle, ControlPosition} = google.maps
	GeolocationRequest = sellstome.geolocation.GeolocationRequest
	#module constant
	TAB_MAP_VIEW = "mapView"
	TAB_BLOG_VIEW = "blogView"
	TAB_MICROBLOG_VIEW = "microblogView"

	#system events
	TAB_SWITCH_L = "tab:switch.local";

	initialize = () ->
		new AppController()
		return

	class AppController extends Backbone.Controller
		tabControl: null
		mapView: null
		blogView: null
		microblogView: null

		initialize: () ->
			@tabControl = new TabView({el: jQuery("[id=changeViewTab]").get(0)})
			@tabControl.bind TAB_SWITCH_L , @_changeView, this
			@mapView = new MapView({el: jQuery("[id=map]").get(0)})
			@mapView.render()
			return this

		_changeView: ( choosenTab ) ->
			alert choosenTab
			return this

	class SearchController extends Backbone.Controller

  # Handle event binding for the view operations
  # fire event tab selected for all interested parties
	class TabView extends Backbone.View
		initialize: () ->
			return

		events:
			"click .tabItem": "_tabSelected"

		_tabSelected: (event) ->
			choosenTab = event.target.id
			@trigger TAB_SWITCH_L, choosenTab
			return

	#initialize map view
	class MapView extends Backbone.View
		#Map reference
		map: null

		initialize: () ->
			return

		render: () ->
			request = new GeolocationRequest()
			positionMap = (position) ->
				mapCenterPosition = new LatLng(position.coords.latitude, position.coords.longitude)
				options =
					zoom: 12
					center: mapCenterPosition
					mapTypeId: MapTypeId.ROADMAP
					disableDefaultUI: true
				@map = new Map(@el, options)
			positionMap = _.bind(positionMap, this)
			request.getCurrentPosition positionMap, (error) ->
				throw error
			return

	exports.initialize = initialize

jQuery(document).ready () ->
	sellstome.search.initialize()