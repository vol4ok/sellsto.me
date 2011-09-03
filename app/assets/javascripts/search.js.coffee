#= require lang
#= require map/controls
#= require map/overlays
#= require map/geolocation
#= require jquery
#= require backbone
#= require backbone_ext

namespace "sellstome.search", (exports) ->

	{LatLng, Marker, MapTypeId, ZoomControlStyle, 
		Map, Circle, ControlPosition, OverlayView} = google.maps
	GeolocationRequest = sellstome.geolocation.GeolocationRequest

	#module constant
	TAB_MAP_VIEW = "mapView"
	TAB_BLOG_VIEW = "blogView"
	TAB_MICROBLOG_VIEW = "microblogView"

	#system events
	TAB_SWITCH_L = "tab:switch.local";
	SEARCH_SEARCH_L = "search:search.local";

	initialize = () ->
		new AppController()
		return
		
	#TODO: we need use Router here instead of Controller, for handling url
	class AppController extends Backbone.Controller
		tabControl: null
		mapView: null
		blogView: null
		microblogView: null
		searchController: null

		initialize: () ->
			@tabControl = new TabView({el: jQuery("[id=changeViewTab]").get(0)})
			@tabControl.bind TAB_SWITCH_L , @_changeView, this
			@mapView = new MapView({el: jQuery("[id=map]").get(0)})
			@mapView.render()
			@searchController = new SearchController()
			return this

		_changeView: ( choosenTab ) ->
			alert "Sorry, but this feature is not implemented yet"
			return this

	#Responsible for handling a search operation
	class SearchController extends Backbone.Controller
		searchControl: null

		initialize: () ->
			@searchControl = new SearchView({el: jQuery("[id=query-view]").get(0)})
			@searchControl.bind SEARCH_SEARCH_L, @_onSearch, this
			return

		_onSearch: (query) ->
			alert "Sorry, but this featuew is not implemented yet"
			return


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
			positionMap = (position) =>
				mapCenterPosition = new LatLng(position.coords.latitude, position.coords.longitude)
				options =
					zoom: 12
					center: mapCenterPosition
					mapTypeId: MapTypeId.ROADMAP
					disableDefaultUI: true
				@map = new Map(@el, options)
			
			errorCallback = (error) =>
				options =
					zoom: 12
					mapTypeId: MapTypeId.ROADMAP
					disableDefaultUI: true
				@map = new Map(@el, options)
			request.getCurrentPosition(positionMap, errorCallback)
			return

	class SearchView extends Backbone.View
		events:
			"keypress .query": "_search"

		initialize: () ->
			return

		_search: (event) ->
			if event.which is 13
				@trigger SEARCH_SEARCH_L, jQuery(event.target).val()
				return false
			else
				true
			return

	exports.initialize = initialize

jQuery(document).ready () ->
	sellstome.search.initialize()