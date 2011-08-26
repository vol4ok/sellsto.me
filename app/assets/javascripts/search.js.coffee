#= require lang
#= require map/controls
#= require map/overlays
#= require map/geolocation
#= require jquery

namespace "sellstome.map", (exports) ->

	{LatLng, Marker, MapTypeId, ZoomControlStyle, 
		Map, Circle, ControlPosition} = google.maps
	GeolocationRequest = sellstome.geolocation.GeolocationRequest

	initialize = (el) ->
		request = new GeolocationRequest()
		request.getCurrentPosition (pos) ->
			p = new LatLng(pos.coords.latitude, pos.coords.longitude)
			opt =
				zoom: 12
				center: p
				mapTypeId: MapTypeId.ROADMAP
				disableDefaultUI: yes
			map = new Map(el, opt)
		, (error) ->
			throw error

	exports.initialize = initialize

jQuery(document).ready () ->
    sellstome.map.initialize($('#map')[0])