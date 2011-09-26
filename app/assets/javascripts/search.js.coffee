#= require lang
#= require jquery
#= require backbone
#= require backbone_ext
#= require module/sellstome
#= require module/generators
#= require module/map/overlays
#= require module/map/geolocation
#= require module/map/controls

namespace "sellstome.search", (exports) ->

	{LatLng, Marker, MapTypeId, ZoomControlStyle, 
		Map, Circle, ControlPosition, OverlayView} = google.maps
	GoogleEventHub = google.maps.event
	{GeolocationRequest} = sellstome.geolocation
	{expandApiURL} = sellstome.common
	{AdInfo}=sellstome.map
	{generateCircle,generateRect,generatePriceBubble} = sellstome.generators
	{rand} = sellstome.helpers

	#module constant
	TAB_MAP_VIEW = "mapView"
	TAB_BLOG_VIEW = "blogView"
	TAB_MICROBLOG_VIEW = "microblogView"
	SEARCH_URL = expandApiURL("/search")
	
	root.$cache ?= {}

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
		###@type {google.map.Map}###
		map: null
		###@type {array}###
		searchResults: null
		###@type {sellstome.search.SearchResultView}###
		selectedSearchResult: null

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
				#searchResultView.bind(MAP_SHOW_DETAILS_L, @_onShowAdInfo, this)
				#searchResultView.bind(MAP_HIDE_DETAILS_L, @_onHideAdInfo, this)
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

		###
		Ensures that only one dialog is opened on map.
		@param {sellstome.search.SearchResultView}
		todo zhugrov - I think here would be better to add toogle semantics
		###
		_onShowAdInfo: (searchResultView) ->
			if not _.isNull( @selectedSearchResult )
				@selectedSearchResult.closeAdInfo()
			@selectedSearchResult = searchResultView
			return

		_onHideAdInfo: (searchResultView) ->
			@selectedSearchResult = null if searchResultView == @selectedSearchResult
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

	class SearchResultView extends Backbone.DomlessView
			###@type {google.map.Map} reference to Google Map ###
			map: null
			###@type {google.map.Marker} ###
			marker: null
			###@type {sellstome.map.AdInfo} ###
			adInfo: null


			# @constructor
			initialize: () ->
				@map = @options.map
				return
				
			generatePriceMarkers: (price) ->
				unless $cache[price]?
					$cache[price] = {}
					bubble = generatePriceBubble("$#{price}",{
						font: 'bold 14px Arial'
						color: '#444'
						fillStyle: 'rgba(0,200,0,0.6)'
						strokeStyle: 'rgba(0,120,0,0.6)'
					})
					$cache[price][0] = new google.maps.MarkerImage(
						bubble.image,
						new google.maps.Size(bubble.width,bubble.height),
						new google.maps.Point(0,0),
						new google.maps.Point(bubble.anchorX,bubble.anchorY))
					$cache[price]['shape'] = bubble.shape
					
					bubble = generatePriceBubble("$#{price}",{
						font: 'bold 14px Arial'
						color: '#444'
						fillStyle: 'rgba(245,50,50,0.9)'
						strokeStyle: 'rgba(120,20,20,0.9)'
					})
					$cache[price][1] = new google.maps.MarkerImage(
						bubble.image,
						new google.maps.Size(bubble.width,bubble.height),
						new google.maps.Point(0,0),
						new google.maps.Point(bubble.anchorX,bubble.anchorY))
				return $cache[price]
				
			generateCircleMarkers: () ->
				unless $cache['circle']?
					$cache['circle'] = {}
					bubble = generateCircle(5, {
						fillStyle: 'rgba(0,200,0,0.6)'
						strokeStyle: 'rgba(0,120,0,0.6)'
					})
					$cache['circle'][0] = new google.maps.MarkerImage(
						bubble.image,
						new google.maps.Size(bubble.width,bubble.height),
						new google.maps.Point(0,0),
						new google.maps.Point(bubble.anchorX,bubble.anchorY))
					$cache['circle']['shape'] = bubble.shape

					bubble = generateCircle(5, {
						fillStyle: 'rgba(245,50,50,0.9)'
						strokeStyle: 'rgba(120,20,20,0.9)'
					})
					$cache['circle'][1] = new google.maps.MarkerImage(
						bubble.image,
						new google.maps.Size(bubble.width,bubble.height),
						new google.maps.Point(0,0),
						new google.maps.Point(bubble.anchorX,bubble.anchorY))
				return $cache['circle']

			generateRectMarkers: () ->
				unless $cache['rect']?
					$cache['rect'] = {}
					bubble = generateRect(10,10, {
						fillStyle: 'rgba(0,200,0,0.6)'
						strokeStyle: 'rgba(0,120,0,0.6)'
						borderRadius: 3
					})
					$cache['rect'][0] = new google.maps.MarkerImage(
						bubble.image,
						new google.maps.Size(bubble.width,bubble.height),
						new google.maps.Point(0,0),
						new google.maps.Point(bubble.anchorX,bubble.anchorY))
					$cache['rect']['shape'] = bubble.shape

					bubble = generateRect(10,10, {
						fillStyle: 'rgba(245,50,50,0.9)'
						strokeStyle: 'rgba(120,20,20,0.9)'
						borderRadius: 3
					})
					$cache['rect'][1] = new google.maps.MarkerImage(
						bubble.image,
						new google.maps.Size(bubble.width,bubble.height),
						new google.maps.Point(0,0),
						new google.maps.Point(bubble.anchorX,bubble.anchorY))
				return $cache['rect']

			### Render marker on Google Map ###
			render: () ->
				location = @model.get('location')
				price = @model.get('price').toString()

				markerData = @generatePriceMarkers(price)

				@marker = new Marker
					position: new LatLng(location.latitude , location.longitude)
					map: @map
					icon: markerData[0]
					shape: markerData['shape']
					#draggable: true
					#title: price

				GoogleEventHub.addListener( @marker, 'mouseover', (e) =>
					@marker.setZIndex(100)
					@marker.setIcon(markerData[1])
				)

				GoogleEventHub.addListener( @marker, 'mouseout', (e) =>
					@marker.setZIndex(1)
					@marker.setIcon(markerData[0])
				)

				GoogleEventHub.addListener( @marker, 'click', (e) =>
					if _.isNull( @adInfo )
						@openAdInfo()
					else
						@closeAdInfo()
				)

				return this

			openAdInfo: () ->
				@adInfo = new AdInfo
					anchor:       @marker
					description:  @model.get('body')
					map:          @map
				@adInfo.bind( MAP_HIDE_DETAILS_L , @_onClosedAdInfo, this )
				@trigger(MAP_SHOW_DETAILS_L, this)
				return this

			###Closes add info dialog ###
			closeAdInfo: () ->
				@adInfo.removeFromMap()
				@adInfo.unbind( MAP_HIDE_DETAILS_L )
				@adInfo = null
				return this

			_onClosedAdInfo: () ->
				@trigger( MAP_HIDE_DETAILS_L, this )
				return this

			### Remove marker from google map ###
			remove: () ->
				@marker.setMap null
				# remove all referenced to this object
				GoogleEventHub.clearInstanceListeners(@marker)
				delete @marker
				return this

	exports.initialize = initialize

jQuery(document).ready () ->
	sellstome.search.initialize()