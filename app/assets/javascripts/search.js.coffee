#= require lang
#= require sellstome
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
	expandApiURL = sellstome.common.expandApiURL

	#module constant
	TAB_MAP_VIEW = "mapView"
	TAB_BLOG_VIEW = "blogView"
	TAB_MICROBLOG_VIEW = "microblogView"
	SEARCH_URL = expandApiURL("/search")

	#system events
	TAB_SWITCH_L = "tab:switch.local";
	SEARCH_SEARCH_L = "search:search.local";

	initialize = () ->
		new AppController()
		return

	######################################################
	#                                                    #
	#                  CONTROLLERS                       #
	#                                                    #
	######################################################

	class AppController extends Backbone.Controller
		# @type {Backbone.View}
		tabControl: null
		# @type {Backbone.View}
		mapView: null
		# @type {Backbone.View}
		blogView: null
		# @type {Backbone.View}
		microblogView: null
		# @type {Backbone.Controller}
		searchRouter: null

		initialize: () ->
			@tabControl = new TabView({el: jQuery("[id=changeViewTab]").get(0)})
			@tabControl.bind TAB_SWITCH_L , @_changeView, this
			@mapView = new MapView({el: jQuery("[id=map]").get(0)})
			@mapView.render()
			@searchRouter = new SearchRouter(mapView: @mapView)
			# Initialize routing system.
			Backbone.history.start({pushState: true})
			return this

		_changeView: ( choosenTab ) ->
			alert "Sorry, but this feature is not implemented yet"
			return this

	#Responsible for handling a search operation
	class SearchRouter extends Backbone.Router
		# @type {Backbone.View}
		searchControl: null
		# @type {Backbone.Collection}
		searchResults: null
		# @type {Backbone.View}
		mapView: null

		routes:
			"search/:query": "_onSearch"
			"search/:query/:page": "_onSearch"

		# @constructor
		# @param options {object} set of initial params
		initialize: ( options ) ->
			@searchControl = new SearchView({el: jQuery("[id=query-view]").get(0)})
			@searchControl.bind SEARCH_SEARCH_L, @_onSearch, this
			@searchResults = new SearchResultList()
			@mapView = options.mapView
			@searchResults.bind "add" , @mapView.renderSearchResult, @mapView
			@searchResults.bind "reset" , @mapView.renderSearchResults, @mapView
			return this

		_onSearch: (query) ->
			@searchResults.fetch()
			return this


	######################################################
	#                                                    #
	#                    MODELS                          #
	#                                                    #
	######################################################


	class SearchResult extends Backbone.Model
		idAttribute: "_id"

	class SearchResultList extends Backbone.Collection
		model: SearchResult
		url: SEARCH_URL

	######################################################
	#                                                    #
	#                    VIEWS                           #
	#                                                    #
	######################################################

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
		#@type {google.map.Map}
		map: null
		#@type {array}
		searchResults: null

		initialize: () ->
			@searchResults = new Array()
			return this

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
					center: new LatLng( 53.90, 27.55 )
					mapTypeId: MapTypeId.ROADMAP
					disableDefaultUI: true
				@map = new Map(@el, options)
			request.getCurrentPosition(positionMap, errorCallback)
			return this

		# Renders the list of search results on map
		renderSearchResults: ( searchList ) ->
			#remove all old elements from map
			while @searchResults.length != 0
				oldSearchResultView = @searchResults.pop()
				oldSearchResultView.remove()

			searchList.each (searchResult) =>
				searchResultView = new SearchResultView({ model: searchResult, map: @map })
				searchResultView.render()
				@searchResults.push searchResultView
				return
			return this

		#Render single search result
		renderSearchResult: ( searchResult ) ->
			searchResultView = new SearchResultView({ model: searchResult, map: @map })
			searchResultView.render()
			@searchResults.push searchResultView
			return this



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

	class SearchResultView extends Backbone.DomlessView
			#@type {google.map.Map} reference to Google Map
			map: null
			#@type {google.map.Marker}
			marker: null
			# @constructor
			initialize: () ->
				@map = @options.map
				return
			#render marker on Google Map
			render: () ->
				_location = @model.get("location")
				@marker = new Marker
					position: new LatLng(_location.latitude , _location.longitude)
					map: @map
					title: @model.get("price").toString()
				return

			remove: () ->
				@marker.setMap null
				return

	exports.initialize = initialize

jQuery(document).ready () ->
	sellstome.search.initialize()